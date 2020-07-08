//
//  APIClient.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-06-13.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    
    var description: String {
        return self.rawValue
    }
}

enum HTTPContentType: String {
    case applicationXWWWFromUrlencoded = "application/x-www-form-urlencoded"
    case applicationJSON = "application/json"
}

struct HTTPHeader {
    let field: String
    let value: String
}

class APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?
    var contentType: HTTPContentType
    
    init(method: HTTPMethod, path: String, contentType: HTTPContentType = .applicationJSON) {
        self.method = method
        self.path = path
        self.contentType = contentType
    }
}

struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
}

extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.decodingFailure
        }
        let decodedJSON = try JSONDecoder().decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode, body: decodedJSON)
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailure
}

enum APIResult<Body> {
    case success(APIResponse<Body>)
    case failure(APIError)
}

class APIClient: NSObject {
    
    typealias APIClientCompletion = (APIResult<Data?>) -> Void
    
    private var hostName = UserDefaults.shared.apiHostName
    
    private var baseURL: URL {
        return URL(string: "https://\(hostName)")!
    }
    
    private var userAgent: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "ivpn/ios \(version)"
        }
        
        return "ivpn/ios"
    }
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": userAgent]
        
        if APIAccessManager.shared.isHostIpAddress(host: hostName) {
            return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        return URLSession(configuration: configuration)
    }
    
    func perform(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = request.queryItems
        
        if request.method == .post {
            urlComponents.queryItems = []
        }
        
        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        if request.method == .post, let queryItems = request.queryItems, !queryItems.isEmpty {
            switch request.contentType {
            case .applicationXWWWFromUrlencoded:
                urlRequest.httpBody = query(queryItems).data(using: .utf8)
            case .applicationJSON:
                let parameters = queryItems.reduce([String: Any]()) { (dict, queryItem) -> [String: Any] in
                    var dict = dict
                    
                    switch queryItem.value {
                    case "true":
                        dict[queryItem.name] = true
                    case "false":
                        dict[queryItem.name] = false
                    default:
                        dict[queryItem.name] = queryItem.value
                    }
                    
                    return dict
                }
                
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                } catch let error {
                    print(error.localizedDescription)
                }
                
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        let task = session.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                if let nextHost = APIAccessManager.shared.nextHostName(failedHostName: self.hostName) {
                    self.retry(request, nextHost: nextHost) { result in
                        completion(result)
                    }
                    return
                }
                
                completion(.failure(.requestFailed))
                return
            }
            completion(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
        }
        task.resume()
    }
    
    func retry(_ request: APIRequest, nextHost: String, _ completion: @escaping APIClientCompletion) {
        hostName = nextHost
        perform(request) { result in
            switch result {
            case .success:
                UserDefaults.shared.set(self.hostName, forKey: UserDefaults.Key.apiHostName)
            case .failure:
                break
            }
            
            completion(result)
        }
    }
    
    func cancel() {
        session.invalidateAndCancel()
    }
    
    private func query(_ queryItems: [URLQueryItem]) -> String {
        var components: [(String, String)] = []
        for queryItem in queryItems {
            components += queryComponents(queryItem.name, queryItem.value ?? "")
        }
        
        return (components.map { "\($0)=\($1)" }).joined(separator: "&")
    }
    
    private func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.append((
                percentEncodeString(key),
                percentEncodeString("\(value)"))
            )
        }
        
        return components
    }
    
    private func percentEncodeString(_ originalObject: Any) -> String {
        if originalObject is NSNull {
            return "null"
        } else {
            var reserved = CharacterSet.urlQueryAllowed
            reserved.remove(charactersIn: ": #[]@!$&'()*+, ;=")
            return String(describing: originalObject)
                .addingPercentEncoding(withAllowedCharacters: reserved) ?? ""
        }
    }
    
}

// MARK: - URLSessionDelegate -

extension APIClient: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if checkValidity(of: challenge, tlsHostName: Config.TlsHostName) {
            let proposedCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, proposedCredential)
            return
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    private func checkValidity(of challenge: URLAuthenticationChallenge, tlsHostName: String) -> Bool {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            return false
        }
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return false
        }
        
        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let commonName = SecCertificateCopySubjectSummary(serverCert) as String? else {
                return false
        }
        
        guard commonName.contains(tlsHostName) else {
            return false
        }
        
        guard challenge.protectionSpace.host == hostName else {
            return false
        }
        
        return true
    }
    
}
