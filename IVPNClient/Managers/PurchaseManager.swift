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

class PurchaseManager: NSObject {
    
    // MARK: - Properties -
    
    static let shared = PurchaseManager()
    
    var canMakePurchases: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private(set) var products: [Product] = []
    
    private var apiEndpoint: String {
        if KeyChain.sessionToken != nil {
            if !Application.shared.serviceStatus.isNewStyleAccount() {
                return Config.apiPaymentAddLegacy
            }
            
            return Config.apiPaymentAdd
        }
        
        return Config.apiPaymentInitial
    }
    
    // MARK: - Methods -
    
    func startObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    func loadProducts() async throws {
        products = try await Product.products(for: ProductId.all)
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
        case .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    func finishPurchase(transaction: Transaction, completion: @escaping (ServiceStatus?, ErrorResult?) -> Void) {
        let endpoint = apiEndpoint
        let params = purchaseParams(transaction: transaction, endpoint: endpoint)
        let request = ApiRequestDI(method: .post, endpoint: endpoint, params: params)
        
        ApiService.shared.requestCustomError(request) { (result: ResultCustomError<SessionStatus, ErrorResult>) in
            switch result {
            case .success(let sessionStatus):
                Application.shared.serviceStatus = sessionStatus.serviceStatus
                // try await transaction.finish()
                completion(sessionStatus.serviceStatus, nil)
                log(.info, message: "Purchase was successfully finished.")
            case .failure(let error):
                let defaultErrorResult = ErrorResult(status: 500, message: "Purchase was completed but service cannot be activated. Restart application to retry.")
                completion(nil, error ?? defaultErrorResult)
                log(.error, message: "There was an error with purchase completion: \(error?.message ?? "")")
            }
        }
    }
    
    func getProduct(id: String) -> Product? {
        for product in products where product.id == id {
            return product
        }
        
        return nil
    }
    
    // MARK: - Private methods -
    
    private func base64receipt() -> String {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                return receiptData.base64EncodedString(options: [])
            }
            catch {
                log(.error, message: "Couldn't read receipt data with error: \(error.localizedDescription)")
            }
        }
        
        return ""
    }
    
    private func purchaseParams(transaction: Transaction, endpoint: String) -> [URLQueryItem] {
        let productId = transaction.productID
        let transactionId = transaction.id.formatted()
        let receipt = base64receipt()
        
        switch endpoint {
        case Config.apiPaymentInitial:
            return [
                URLQueryItem(name: "account_id", value: KeyChain.tempUsername ?? ""),
                URLQueryItem(name: "product_id", value: productId),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: receipt)
            ]
        case Config.apiPaymentAdd:
            return [
                URLQueryItem(name: "session_token", value: KeyChain.sessionToken ?? ""),
                URLQueryItem(name: "product_id", value: productId),
                URLQueryItem(name: "transaction_id", value: transactionId),
                URLQueryItem(name: "receipt", value: receipt)
            ]
        case Config.apiPaymentAddLegacy:
            return [
                URLQueryItem(name: "username", value: KeyChain.username ?? ""),
                URLQueryItem(name: "productId", value: productId),
                URLQueryItem(name: "transactionId", value: transactionId),
                URLQueryItem(name: "receiptData", value: receipt)
            ]
        default:
            return []
        }
    }
    
    private func restorePurchaseParams() -> [URLQueryItem] {
        let receipt = base64receipt()
        return [URLQueryItem(name: "receipt", value: receipt)]
    }
    
}

// MARK: - SKPaymentTransactionObserver -

extension PurchaseManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
}
