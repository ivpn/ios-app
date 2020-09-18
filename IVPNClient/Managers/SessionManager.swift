//
//  SessionManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-07-26.
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

@objc protocol SessionManagerDelegate: class {
    func createSessionStart()
    func createSessionSuccess()
    func createSessionFailure(error: Any?)
    func createSessionTooManySessions(error: Any?)
    func createSessionAuthenticationError()
    func createSessionServiceNotActive()
    func createSessionAccountNotActivated(error: Any?)
    func deleteSessionStart()
    func deleteSessionSuccess()
    func deleteSessionFailure()
    func deleteSessionSkip()
    func sessionStatusSuccess()
    func sessionStatusNotFound()
    func sessionStatusExpired()
    func sessionStatusFailure()
}

class SessionManager {
    
    // MARK: - Properties -
    
    weak var delegate: SessionManagerDelegate?
    
    static var sessionExists: Bool {
        return KeyChain.sessionToken != nil
    }
    
    // MARK: - Methods -
    
    func createSession(force: Bool = false, connecting: Bool = false, username: String? = nil) {
        delegate?.createSessionStart()
        
        if AppKeyManager.isKeyPairRequired || connecting {
            AppKeyManager.generateKeyPair()
            UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
        }
        
        let params = sessionNewParams(force: force, username: username)
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionNew, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<Session, ErrorResultSessionNew>) in
            switch result {
            case .success(let model):
                Application.shared.serviceStatus = model.serviceStatus
                Application.shared.authentication.logIn(session: model)
                
                if !model.serviceStatus.isActive {
                    self.delegate?.createSessionServiceNotActive()
                    return
                }
                
                self.delegate?.createSessionSuccess()
            case .failure(let error):
                if let error = error {
                    if error.status == 401 {
                        self.delegate?.createSessionAuthenticationError()
                        return
                    }
                    
                    if error.status == 602 {
                        self.delegate?.createSessionTooManySessions(error: error)
                        return
                    }
                    
                    if error.status == 11005 {
                        self.delegate?.createSessionAccountNotActivated(error: error)
                        return
                    }
                }
                
                self.delegate?.createSessionFailure(error: error)
            }
        }
    }
    
    func getSessionStatus() {
        guard SessionManager.sessionExists else { return }
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionStatus, params: ApiService.authParams)
        
        ApiService.shared.request(request) { (result: Result<SessionStatus>) in
            switch result {
            case .success(let model):
                Application.shared.serviceStatus = model.serviceStatus
                
                if model.serviceActive {
                    self.delegate?.sessionStatusSuccess()
                    return
                }
                
                if model.serviceExpired {
                    self.delegate?.sessionStatusExpired()
                    return
                }
                
                self.delegate?.sessionStatusFailure()
            case .failure(let error):
                if error?.code == 601 {
                    self.delegate?.sessionStatusNotFound()
                    return
                }
                
                if error?.code == 702 {
                    Application.shared.serviceStatus.isActive = false
                }
                
                self.delegate?.sessionStatusFailure()
            }
        }
    }
    
    func deleteSession() {
        guard SessionManager.sessionExists else {
            delegate?.deleteSessionSkip()
            return
        }
        
        delegate?.deleteSessionStart()
        
        let params = sessionDeleteParams()
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionDelete, params: params)
        
        ApiService.shared.request(request) { (result: Result<SuccessResult>) in
            switch result {
            case .success(let model):
                if model.statusOK {
                    self.delegate?.deleteSessionSuccess()
                } else {
                    self.delegate?.deleteSessionFailure()
                }
            case .failure:
                self.delegate?.deleteSessionFailure()
            }
        }
    }
    
    // MARK: - Helper methods -
    
    private func sessionNewParams(force: Bool = false, username: String? = nil) -> [URLQueryItem] {
        let username = username ?? Application.shared.authentication.getStoredUsername()
        var params = [URLQueryItem(name: "username", value: username)]
        
        if let wgPublicKey = KeyChain.wgPublicKey {
            params.append(URLQueryItem(name: "wg_public_key", value: wgPublicKey))
        }
        
        if force {
            params.append(URLQueryItem(name: "force", value: "true"))
        }
        
        return params
    }
    
    private func sessionDeleteParams(force: Bool = false) -> [URLQueryItem] {
        let sessionToken = Application.shared.authentication.getStoredSessionToken()
        return [URLQueryItem(name: "session_token", value: sessionToken)]
    }
    
}
