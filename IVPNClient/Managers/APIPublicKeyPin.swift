//
//  APIPublicKeyPin.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-01-05.
//  Copyright (c) 2021 Privatus Limited.
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
import CryptoKit
import CommonCrypto

class APIPublicKeyPin {
    
    // MARK: - Properties -
    
    private let hashes = [
        "g6WEFnt9DyTi70nW/fufsZNw83vFpcmIhMuDPQ1MFcI=",
        "KCcpK9y22OrlapwO1/oP8q3LrcDM9Jy9lcfngg2r+Pk=",
        "iRHkSbdOY/YD8EE5fpl8W0P8EqmfkBRTADEegR2/Wnc=",
        "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="
    ]
    
    // MARK: - Methods -
    
    public func validate(serverTrust: SecTrust, domain: String?) -> Bool {
        if let domain = domain {
            let policies = NSMutableArray()
            policies.add(SecPolicyCreateSSL(true, domain as CFString))
            SecTrustSetPolicies(serverTrust, policies)
        }
        
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)
        
        guard status == errSecSuccess else {
            return false
        }
        
        for index in 0..<SecTrustGetCertificateCount(serverTrust) {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index),
                  let publicKey = SecCertificateCopyKey(certificate),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) else {
                return false
            }
            
            let keyHash = hash(data: (publicKeyData as NSData) as Data)
            if hashes.contains(keyHash) {
                return true
            }
        }
        
        return false
    }
    
    private func hash(data: Data) -> String {
        // Add the missing ASN1 header for public keys to re-create the subject public key info
        let rsa4096Asn1Header: [UInt8] = [
            0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
        ]
        var keyWithHeader = Data(rsa4096Asn1Header)
        keyWithHeader.append(data)
        
        return Data(SHA256.hash(data: keyWithHeader)).base64EncodedString()
    }
    
}
