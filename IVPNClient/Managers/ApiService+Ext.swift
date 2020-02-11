//
//  ApiService+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 08/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

extension ApiService {
    
    // MARK: - Methods -
    
    func getServersList(storeInCache: Bool, completion: @escaping (ServersUpdateResult) -> Void) {
        let request = APIRequest(method: .get, path: Config.apiServersFile)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        log(info: "Fetching servers list...")
        
        APIClient().perform(request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                guard Config.useDebugServers == false else { return }
                
                if let data = response.body {
                    let serversList = VPNServerList(withJSONData: data, storeInCache: storeInCache)
                    
                    if serversList.servers.count > 0 {
                        log(info: "Fetching servers list completed successfully")
                        completion(.success(serversList))
                        return
                    }
                }
                
                log(info: "Error updating servers list (probably parsing error)")
                completion(.error)
            case .failure:
                log(info: "Error fetching servers list")
                completion(.error)
            }
        }
    }
    
}
