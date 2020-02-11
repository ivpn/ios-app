//
//  File.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 9/27/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class ApiService {
    
    // MARK: - Properties -
    
    static let shared = ApiService()
    
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        log(info: "\(requestName) started")
        
        APIClient().perform(request) { result in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
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
                        
                        do {
                            let errorResponse = try decoder.decode(ErrorResult.self, from: data)
                            let error = self.getServiceError(message: errorResponse.message, code: errorResponse.status)
                            completion(.failure(error))
                            log(info: "\(requestName) error response")
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
    }
    
    func requestCustomError<T, E>(_ requestDI: ApiRequestDI, completion: @escaping (ResultCustomError<T, E>) -> Void) {
        let requestName = "\(requestDI.method.description) \(requestDI.endpoint)"
        let request = APIRequest(method: requestDI.method, path: requestDI.endpoint)
        
        if let params = requestDI.params {
            request.queryItems = params
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        log(info: "\(requestName) started")
        
        APIClient().perform(request) { result in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
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
                        
                        do {
                            let errorResponse = try decoder.decode(E.self, from: data)
                            completion(.failure(errorResponse))
                            log(info: "\(requestName) error response")
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
