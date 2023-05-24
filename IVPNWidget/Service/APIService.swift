//
//  APIService.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-12.
//  Copyright (c) 2023 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

protocol APIService {
    func request<T>(_ requestDI: ApiRequestDI, completion: @escaping (Result<T>) -> Void)
    func getServiceError(message: String, code: Int) -> NSError
}

class WidgetAPIService: APIService {
    
    func request<T>(_ requestDI: ApiRequestDI, completion: @escaping (Result<T>) -> Void) {
        let request = APIRequest(method: requestDI.method, path: requestDI.endpoint, addressType: requestDI.addressType)
        
        if let params = requestDI.params {
            request.queryItems = params
        }
        
        APIClient().perform(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let data = response.body {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        do {
                            let successResponse = try decoder.decode(T.self, from: data)
                            completion(.success(successResponse))
                            return
                        } catch {}
                    }
                    
                    completion(.failure(nil))
                case .failure:
                    completion(.failure(nil))
                }
            }
        }
    }
    
    func getServiceError(message: String, code: Int = 99) -> NSError {
        return NSError(
            domain: "ApiServiceDomain",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
    
}
