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
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: true) { result in
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
    
    func completePurchase(purchase: PurchaseDetails, completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        let params = purchaseParams(purchase: purchase)
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSubscription, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<Session, ErrorResult>) in
            switch result {
            case .success(let session):
                SwiftyStoreKit.finishTransaction(purchase.transaction)
                Application.shared.serviceStatus = session.serviceStatus
                Application.shared.authentication.logIn(session: session)
                KeyChain.email = nil
                completion(session.serviceStatus, nil)
                log(info: "Purchase was successfully finished.")
            case .failure(let error):
                let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
                completion(nil, error ?? defaultErrorResult)
                log(error: "There was an error with purchase completion: \(error?.message ?? "")")
            }
        }
    }
    
    func finishIncompletePurchases(completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: false) { products in
            self.completePurchases(products: products) { serviceStatus, error in
                completion(serviceStatus, error)
            }
        }
    }
    
    func completePurchases(products: [Purchase], completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        for product in products {
            log(info: "Found incomplete purchase. Completing purchase...")
            
            if product.transaction.transactionState == .purchased {
                let params = finishPurchaseParams(product: product)
                let request = ApiRequestDI(method: .post, endpoint: Config.apiSubscription, params: params)
                
                ApiService.shared.requestCustomError(request) { (result: ResultCustomError<Session, ErrorResult>) in
                    switch result {
                    case .success(let session):
                        SwiftyStoreKit.finishTransaction(product.transaction)
                        Application.shared.serviceStatus = session.serviceStatus
                        Application.shared.authentication.logIn(session: session)
                        KeyChain.email = nil
                        completion(session.serviceStatus, nil)
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
    
    func productPrice(subscriptionType: SubscriptionType) -> String {
        guard !IAPManager.shared.products.isEmpty else { return "" }
        let identifier = subscriptionType.getProductId()
        guard let product = IAPManager.shared.getProduct(identifier: identifier) else { return "" }
        return IAPManager.shared.productPrice(product: product)
    }
    
    // MARK: - Private methods -
    
    private func purchaseParams(purchase: PurchaseDetails) -> [URLQueryItem] {
        let username = Application.shared.authentication.getStoredUsername()
        let transactionId = purchase.transaction.transactionIdentifier ?? "Unknown transaction ID"
        let base64receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []) ?? ""
        
        if let email = KeyChain.email, let password = KeyChain.password {
            return [
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "password_confirmation", value: password),
                URLQueryItem(name: "product_id", value: purchase.product.productIdentifier),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt_data", value: base64receipt)
            ]
        }
        
        return [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "product_id", value: purchase.product.productIdentifier),
            URLQueryItem(name: "transaction_id", value: transactionId),
            URLQueryItem(name: "receipt_data", value: base64receipt)
        ]
    }
    
    private func finishPurchaseParams(product: Purchase) -> [URLQueryItem] {
        let username = Application.shared.authentication.getStoredUsername()
        let transactionId = product.transaction.transactionIdentifier ?? ""
        let base64receipt = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []) ?? ""
        
        if let email = KeyChain.email, let password = KeyChain.password {
            return [
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "password_confirmation", value: password),
                URLQueryItem(name: "product_id", value: product.productId),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt_data", value: base64receipt)
            ]
        }
        
        return [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "productId", value: product.productId),
            URLQueryItem(name: "transactionId", value: transactionId),
            URLQueryItem(name: "receiptData", value: base64receipt)
        ]
    }
    
}
