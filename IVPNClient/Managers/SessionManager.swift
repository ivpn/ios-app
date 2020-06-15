//
//  SessionManager.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 26/07/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

@objc protocol SessionManagerDelegate: class {
    func createSessionStart()
    func createSessionSuccess()
    func createSessionFailure(error: Any?)
    func createSessionTooManySessions(error: Any?)
    func createSessionAuthenticationError()
    func createSessionServiceNotActive()
    func createSessionAccountNotActivated()
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
    
    func createSession(force: Bool = false, connecting: Bool = false) {
        delegate?.createSessionStart()
        
        if AppKeyManager.isKeyPairRequired || connecting {
            AppKeyManager.generateKeyPair()
            UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
        }
        
        let params = sessionNewParams(force: force)
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
                    
                    // Signup not completed with initial payment
                    if error.status == 500 && KeyChain.tempUsername != nil {
                        self.delegate?.createSessionAccountNotActivated()
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
    
    private func sessionNewParams(force: Bool = false) -> [URLQueryItem] {
        let username = Application.shared.authentication.getStoredUsername()
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
