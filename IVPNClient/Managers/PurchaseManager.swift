//
//  PurchaseManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-12-04.
//  Copyright (c) 2023 IVPN Limited.
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

import StoreKit

@objc protocol PurchaseManagerDelegate: AnyObject {
    func purchaseStart()
    func purchasePending()
    func purchaseSuccess(service: Any?, extended: Bool)
    func purchaseError(error: Any?)
}

class PurchaseManager: NSObject {
    
    // MARK: - Properties -
    
    static let shared = PurchaseManager()
    
    weak var delegate: PurchaseManagerDelegate?
    
    var canMakePurchases: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    var observerTask: Task<Void, Error>? = nil
    
    private(set) var products: [Product] = []
    
    private var apiEndpoint: String {
        guard let _ = KeyChain.sessionToken else {
            return Config.apiPaymentInitial
        }
        
        return Application.shared.serviceStatus.isNewStyleAccount() ? Config.apiPaymentAdd : Config.apiPaymentAddLegacy
    }
    
    deinit {
        stopObserver()
    }
    
    // MARK: - Methods -
    
    func loadProducts() async throws {
        products = try await Product.products(for: ProductId.all)
    }
    
    func getProduct(id: String) -> Product? {
        for product in products where product.id == id {
            return product
        }
        
        return nil
    }
    
    func purchase(_ productId: String) async throws -> Product.PurchaseResult? {
        guard let product = getProduct(id: productId) else {
            return nil
        }
        
        delegate?.purchaseStart()
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            log(.info, message: "[Store] Completing successful in-app purchase \(productId)")
            self.complete(transaction)
            break
        case .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            log(.info, message: "[Store] Purchase \(productId): success, unverified")
            delegate?.purchaseError(error: ErrorResult(status: 500, message: "Purchase is unverified."))
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            log(.info, message: "[Store] Purchase \(productId): pending")
            delegate?.purchasePending()
            break
        case .userCancelled:
            // ^^^
            log(.info, message: "[Store] Purchase \(productId): userCancelled")
            delegate?.purchaseError(error: ErrorResult(status: 500, message: "User canelled the purchase."))
            break
        @unknown default:
            break
        }
        
        return result
    }
    
    func startObserver() {
        observerTask = Task(priority: .background) {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.revocationDate == nil {
                    log(.info, message: "[Store] Completing unfinished purchase \(transaction.productID)")
                    complete(transaction)
                }
            }
        }
    }
    
    func stopObserver() {
        observerTask?.cancel()
    }
    
    func restorePurchases(completion: @escaping (Account?, ErrorResult?) -> Void) {
        Task {
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.revocationDate == nil {
                    self.getAccountFor(transaction: transaction) { account, error in
                        completion(account, error)
                    }
                    return
                }
            }
            
            let error = ErrorResult(status: 500, message: "There are no purchases to restore.")
            log(.error, message: "[Store] There are no purchases to restore")
            completion(nil, error)
        }
    }
    
    func complete(_ transaction: Transaction) {
        let defaultError = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
        let endpoint = apiEndpoint
        
        guard let params = purchaseParams(transaction: transaction, endpoint: endpoint) else {
            delegate?.purchaseError(error: defaultError)
            return
        }
        
        let request = ApiRequestDI(method: .post, endpoint: endpoint, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<SessionStatus, ErrorResult>) in
            switch result {
            case .success(let sessionStatus):
                Application.shared.serviceStatus = sessionStatus.serviceStatus
                Task {
                    await transaction.finish()
                    self.delegate?.purchaseSuccess(service: sessionStatus.serviceStatus, extended: sessionStatus.extended ?? false)
                    log(.info, message: "[Store] Purchase \(transaction.productID) completed successfully")
                }
            case .failure(let error):
                self.delegate?.purchaseError(error: error ?? defaultError)
                log(.error, message: "[Store] There was an error with purchase completion: \(error?.message ?? "")")
            }
        }
    }
    
    // MARK: - Private methods -
    
    private func getAccountFor(transaction: Transaction, completion: @escaping (Account?, ErrorResult?) -> Void) {
        let defaultError = ErrorResult(status: 500, message: "Purchase was restored but service cannot be activated. Restart application to retry.")
        guard let params = restorePurchaseParams(transaction) else {
            completion(nil, defaultError)
            return
        }
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiPaymentRestore, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<Account, ErrorResult>) in
            switch result {
            case .success(let account):
                KeyChain.username = account.accountId
                completion(account, nil)
                log(.info, message: "[Store] Purchase restored successfully")
            case .failure(let error):
                completion(nil, error ?? defaultError)
                log(.error, message: "[Store] There was an error with restoring purchase: \(error?.message ?? "")")
            }
        }
    }
    
    private func purchaseParams(transaction: Transaction, endpoint: String) -> [URLQueryItem]? {
        let productId = transaction.productID
        let transactionId = String(transaction.id)
        
        switch endpoint {
        case Config.apiPaymentInitial:
            guard let tempUsername = KeyChain.tempUsername else {
                return nil
            }
            return [
                URLQueryItem(name: "account_id", value: tempUsername),
                URLQueryItem(name: "product_id", value: productId),
                URLQueryItem(name: "transaction_id", value: transactionId)
            ]
        case Config.apiPaymentAdd:
            guard let sessionToken = KeyChain.sessionToken else {
                return nil
            }
            return [
                URLQueryItem(name: "session_token", value: sessionToken),
                URLQueryItem(name: "product_id", value: productId),
                URLQueryItem(name: "transaction_id", value: transactionId)
            ]
        case Config.apiPaymentAddLegacy:
            guard let username = KeyChain.username else {
                return nil
            }
            return [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "productId", value: productId),
                URLQueryItem(name: "transactionId", value: transactionId)
            ]
        default:
            return nil
        }
    }
    
    private func restorePurchaseParams(_ transaction: Transaction) -> [URLQueryItem]? {
        let transactionId = String(transaction.id)
        return [URLQueryItem(name: "transaction_id", value: transactionId)]
    }
    
}
