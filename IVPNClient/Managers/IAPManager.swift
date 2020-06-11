//
//  IAPManager.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import StoreKit
import SwiftyStoreKit

class IAPManager {
    
    // MARK: - Properties -
    
    static let shared = IAPManager()
    var products: [SKProduct] = []
    
    var canMakePurchases: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private var apiEndpoint: String {
        if KeyChain.sessionToken != nil {
            let username = Application.shared.authentication.getStoredUsername()
            
            if !ServiceStatus.isNewStyleAccount(username: username) {
                return Config.apiPaymentAddLegacy
            }
            
            return Config.apiPaymentAdd
        }
        
        return Config.apiPaymentInitial
    }
    
    // MARK: - Methods -
    
    func fetchProducts(completion: @escaping ([SKProduct]?, String?) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(ProductIdentifier.all) { result in
            if !result.retrievedProducts.isEmpty {
                self.products = Array(result.retrievedProducts)
                completion(Array(result.retrievedProducts), nil)
                log(info: "Products successfully fetched from App Store.")
            } else if !result.invalidProductIDs.isEmpty {
                completion(nil, "Invalid product identifier")
                log(info: "Invalid App Store product identifier.")
            } else {
                completion(nil, String(describing: result.error))
                log(info: "There was an error with fetching products from App Store.")
            }
        }
    }
    
    func purchaseProduct(identifier: String, completion: @escaping (PurchaseDetails?, String?) -> Void) {
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let purchase):
                completion(purchase, nil)
                log(info: "Product was successfully purchased.")
            case .error(let error):
                switch error.code {
                case .unknown: completion(nil, "Unknown error. Please contact support")
                case .clientInvalid: completion(nil, "Not allowed to make the payment")
                case .paymentCancelled: completion(nil, "Payment cancelled")
                case .paymentInvalid: completion(nil, "The purchase identifier was invalid")
                case .paymentNotAllowed: completion(nil, "The device is not allowed to make the payment")
                case .storeProductNotAvailable: completion(nil, "The product is not available in the current storefront")
                case .cloudServicePermissionDenied: completion(nil, "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: completion(nil, "Could not connect to the network")
                case .cloudServiceRevoked: completion(nil, "User has revoked permission to use this cloud service")
                default: completion(nil, (error as NSError).localizedDescription)
                }
                log(error: "There was an error with purchase.")
            }
        }
    }
    
    func finishIncompletePurchases(completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: false) { products in
            self.completePurchases(products: products, endpoint: self.apiEndpoint) { serviceStatus, error in
                completion(serviceStatus, error)
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Account?, ErrorResult?) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                if let restoreError = results.restoreFailedPurchases.first {
                    let error = ErrorResult(status: 500, message: restoreError.0.localizedDescription)
                    completion(nil, error)
                    log(error: restoreError.0.localizedDescription)
                    return
                }
                
                let error = ErrorResult(status: 500, message: "Unknown error")
                completion(nil, error)
                log(error: "Unknown error")
            } else if results.restoredPurchases.count > 0 {
                self.completeRestoredPurchase(purchase: results.restoredPurchases.first!) { account, error in
                    completion(account, error)
                    log(info: "Purchases are restored.")
                }
            } else {
                let error = ErrorResult(status: 500, message: "There are no purchases to restore.")
                completion(nil, error)
                log(error: "There are no purchases to restore.")
            }
        }
    }
    
    func completePurchase(purchase: PurchaseDetails, completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        let endpoint = apiEndpoint
        let params = purchaseParams(purchase: purchase, endpoint: endpoint)
        let request = ApiRequestDI(method: .post, endpoint: endpoint, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<SessionStatus, ErrorResult>) in
            switch result {
            case .success(let sessionStatus):
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                Application.shared.serviceStatus = sessionStatus.serviceStatus
                completion(sessionStatus.serviceStatus, nil)
                log(info: "Purchase was successfully finished.")
            case .failure(let error):
                let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
                completion(nil, error ?? defaultErrorResult)
                log(error: "There was an error with purchase completion: \(error?.message ?? "")")
            }
        }
    }
    
    func completePurchases(products: [Purchase], endpoint: String, completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        for product in products {
            log(info: "Found incomplete purchase. Completing purchase...")
            
            switch product.transaction.transactionState {
            case .purchased, .restored:
                if product.needsFinishTransaction {
                    let params = finishPurchaseParams(product: product, endpoint: endpoint)
                    let request = ApiRequestDI(method: .post, endpoint: endpoint, params: params)
                    
                    ApiService.shared.requestCustomError(request) { (result: ResultCustomError<SessionStatus, ErrorResult>) in
                        switch result {
                        case .success(let sessionStatus):
                            SwiftyStoreKit.finishTransaction(product.transaction)
                            Application.shared.serviceStatus = sessionStatus.serviceStatus
                            completion(sessionStatus.serviceStatus, nil)
                            log(info: "Purchase was successfully finished.")
                        case .failure(let error):
                            let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
                            completion(nil, error ?? defaultErrorResult)
                            log(error: "There was an error with purchase completion: \(error?.message ?? "")")
                        }
                    }
                }
            case .failed, .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    
    func completeRestoredPurchase(purchase: Purchase, completion: @escaping (Account?, ErrorResult?) -> Void) {
        let params = restorePurchaseParams()
        let request = ApiRequestDI(method: .post, endpoint: Config.apiPaymentRestore, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<Account, ErrorResult>) in
            switch result {
            case .success(let account):
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                KeyChain.username = account.accountId
                completion(account, nil)
                log(info: "Purchase was successfully finished.")
            case .failure(let error):
                let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was restored but service cannot be activated. Restart application to retry.")
                completion(nil, error ?? defaultErrorResult)
                log(error: "There was an error with purchase completion: \(error?.message ?? "")")
            }
        }
    }
    
    func completeRestoredPurchases(products: [Purchase], endpoint: String, completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        for product in products {
            log(info: "Found restored purchase. Completing purchase...")
            
            if product.transaction.transactionState == .purchased {
                let params = finishPurchaseParams(product: product, endpoint: endpoint)
                let request = ApiRequestDI(method: .post, endpoint: endpoint, params: params)
                
                ApiService.shared.requestCustomError(request) { (result: ResultCustomError<SessionStatus, ErrorResult>) in
                    switch result {
                    case .success(let sessionStatus):
                        SwiftyStoreKit.finishTransaction(product.transaction)
                        Application.shared.serviceStatus = sessionStatus.serviceStatus
                        completion(sessionStatus.serviceStatus, nil)
                        log(info: "Purchase was successfully finished.")
                    case .failure(let error):
                        let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
                        completion(nil, error ?? defaultErrorResult)
                        log(error: "There was an error with purchase completion: \(error?.message ?? "")")
                    }
                }
            }
        }
    }
    
    func getProduct(identifier: String) -> SKProduct? {
        for product in products where product.productIdentifier == identifier {
            return product
        }
        
        return nil
    }
    
    func productPrice(product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price) ?? ""
    }
    
    // MARK: - Private methods -
    
    private func purchaseParams(purchase: PurchaseDetails, endpoint: String) -> [URLQueryItem] {
        let transactionId = purchase.transaction.transactionIdentifier ?? "Unknown transaction ID"
        let base64receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []) ?? ""
        
        switch endpoint {
        case Config.apiPaymentInitial:
            return [
                URLQueryItem(name: "account_id", value: KeyChain.tempUsername ?? ""),
                URLQueryItem(name: "product_id", value: purchase.product.productIdentifier),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: base64receipt)
            ]
        case Config.apiPaymentAdd:
            return [
                URLQueryItem(name: "session_token", value: KeyChain.sessionToken ?? ""),
                URLQueryItem(name: "product_id", value: purchase.product.productIdentifier),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: base64receipt)
            ]
        case Config.apiPaymentAddLegacy:
            return [
                URLQueryItem(name: "username", value: KeyChain.username ?? ""),
                URLQueryItem(name: "productId", value: purchase.product.productIdentifier),
                URLQueryItem(name: "transactionId", value: transactionId),
                URLQueryItem(name: "receiptData", value: base64receipt)
            ]
        default:
            return []
        }
    }
    
    private func finishPurchaseParams(product: Purchase, endpoint: String) -> [URLQueryItem] {
        let transactionId = product.transaction.transactionIdentifier ?? ""
        let base64receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []) ?? ""
        
        switch endpoint {
        case Config.apiPaymentInitial:
            return [
                URLQueryItem(name: "account_id", value: KeyChain.tempUsername ?? ""),
                URLQueryItem(name: "product_id", value: product.productId),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: base64receipt)
            ]
        case Config.apiPaymentAdd:
            return [
                URLQueryItem(name: "session_token", value: KeyChain.sessionToken ?? ""),
                URLQueryItem(name: "product_id", value: product.productId),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: base64receipt)
            ]
        case Config.apiPaymentAddLegacy:
            return [
                URLQueryItem(name: "username", value: KeyChain.username ?? ""),
                URLQueryItem(name: "productId", value: product.productId),
                URLQueryItem(name: "transactionId", value: transactionId),
                URLQueryItem(name: "receiptData", value: base64receipt)
            ]
        default:
            return []
        }
    }
    
    private func restorePurchaseParams() -> [URLQueryItem] {
        let base64receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []) ?? ""
        return [URLQueryItem(name: "receipt", value: base64receipt)]
    }
    
}
