//
//  InternetAddress.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-03-01.
//  Copyright (c) 2021 IVPN Limited.
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

/// This enum represents an internet address that can either be IPv4 or IPv6.
///
/// - IPv6: An Internet Address of type IPv6 (e.g.: '::1').
/// - IPv4: An Internet Address of type IPv4 (e.g.: '127.0.0.1').
enum InternetAddress: Hashable {
    case ipv6(sockaddr_in6)
    case ipv4(sockaddr_in)

    /// Human readable host represetnation (e.g. '192.168.1.1' or 'ab:ab:ab:ab:ab:ab:ab:ab').
    var host: String? {
        switch self {
        case .ipv6(var address):
            var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
            inet_ntop(AF_INET6, &address.sin6_addr, &buffer, socklen_t(INET6_ADDRSTRLEN))
            return String(cString: buffer)

        case .ipv4(var address):
            var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            inet_ntop(AF_INET, &address.sin_addr, &buffer, socklen_t(INET_ADDRSTRLEN))
            return String(cString: buffer)
        }
    }

    /// The protocol family that should be used on the socket creation for this address.
    var family: Int32 {
        switch self {
        case .ipv4:
            return PF_INET

        case .ipv6:
            return PF_INET6
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.host)
    }

    init?(dataWithSockAddress data: NSData) {
        let storage = sockaddr_storage.from(unsafeDataWithSockAddress: data)
        switch Int32(storage.ss_family) {
        case AF_INET:
            self = storage.withUnsafeAddress { InternetAddress.ipv4($0.pointee) }

        case AF_INET6:
            self = storage.withUnsafeAddress { InternetAddress.ipv6($0.pointee) }

        default:
            return nil
        }
    }

    /// Returns the address struct (either sockaddr_in or sockaddr_in6) represented as an CFData.
    ///
    /// - parameter port: The port number to associate on the address struct.
    ///
    /// - returns: An address struct wrapped into a CFData type.
    func addressData(withPort port: Int) -> CFData {
        switch self {
        case .ipv6(var address):
            address.sin6_port = in_port_t(port).bigEndian
            return Data(bytes: &address, count: MemoryLayout<sockaddr_in6>.size) as CFData

        case .ipv4(var address):
            address.sin_port = in_port_t(port).bigEndian
            return Data(bytes: &address, count: MemoryLayout<sockaddr_in>.size) as CFData
        }
    }
}

/// Compare InternetAddress(es) by making sure the host representation are equal.
func == (lhs: InternetAddress, rhs: InternetAddress) -> Bool {
    return lhs.host == rhs.host
}
