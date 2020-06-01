//
//  ApiServiceRequest.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 08/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ApiRequestDI {
    let method: HTTPMethod
    let endpoint: String
    let params: [URLQueryItem]?
    let contentType: HTTPContentType?
    
    init(method: HTTPMethod, endpoint: String, params: [URLQueryItem]? = nil, contentType: HTTPContentType? = nil) {
        self.method = method
        self.endpoint = endpoint
        self.params = params
        self.contentType = contentType
    }
}
