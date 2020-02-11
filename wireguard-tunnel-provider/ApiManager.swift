//
//  ApiManager.swift
//  wireguard-tunnel-provider
//
//  Created by Juraj Hilje on 08/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

class ApiManager {
    
    // MARK: - Properties -
    
    static let shared = ApiManager()
    
    static var authParams: [URLQueryItem] {
        guard let sessionToken = KeyChain.sessionToken else {
            return []
        }
        
        return [URLQueryItem(name: "session_token", value: sessionToken)]
    }
    
    // MARK: - Methods -
    
    func request<T>(_ requestDI: ApiRequestDI, completion: @escaping (Result<T>) -> Void) {
        let requestName = "\(requestDI.method.description) \(requestDI.endpoint)"
        let request = APIRequest(method: requestDI.method, path: requestDI.endpoint)
        
        if let params = requestDI.params {
            request.queryItems = params
        }
        
        log(info: "\(requestName) started")
        
        APIClient().perform(request) { result in
            switch result {
            case .success(let response):
                if let data = response.body {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let successResponse = try decoder.decode(T.self, from: data)
                        completion(.success(successResponse))
                        log(info: "\(requestName) success")
                        return
                    } catch {}
                }
                
                completion(.failure(nil))
                log(info: "\(requestName) parse error")
            case .failure:
                log(info: "\(requestName) failure")
                completion(.failure(nil))
            }
        }
    }
    
    // MARK: - Helper methods -
    
    func getServiceError(message: String, code: Int = 99) -> NSError {
        return NSError(
            domain: "ApiServiceDomain",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
    
}
