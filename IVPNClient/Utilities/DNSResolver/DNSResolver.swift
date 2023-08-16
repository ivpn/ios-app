//
//  DNSResolver.swift
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

private let kCopyNoOperation = unsafeBitCast(0, to: CFAllocatorCopyDescriptionCallBack.self)

final class DNSResolver {
    
    private var completion: (([InternetAddress]) -> Void)?
    private var timer: Timer?

    private init() {}

    /// Performs DNS lookups and calls the given completion with the answers that are returned from the name
    /// server(s) that were queried.
    ///
    /// - parameter host:       The host to be looked up.
    /// - parameter timeout:    The connection timeout.
    /// - parameter completion: A completion block that will be called both on failure and success with a list
    ///                         of IPs.
    static func resolve(host: String, timeout: TimeInterval = 8.0, completion: @escaping ([InternetAddress]) -> Void) {
        let callback: CFHostClientCallBack = { host, _, _, info in
            guard let info = info else {
                return
            }
            let retainedSelf = Unmanaged<DNSResolver>.fromOpaque(info)
            let resolver = retainedSelf.takeUnretainedValue()
            resolver.timer?.invalidate()
            resolver.timer = nil

            var resolved: DarwinBoolean = false
            guard let addresses = CFHostGetAddressing(host, &resolved), resolved.boolValue else {
                resolver.completion?([])
                retainedSelf.release()
                return
            }

            let IPs = (addresses.takeUnretainedValue() as NSArray)
                .compactMap { $0 as? NSData }
                .compactMap(InternetAddress.init)

            resolver.completion?(IPs)
            retainedSelf.release()
        }

        let resolver = DNSResolver()
        resolver.completion = completion

        let retainedClosure = Unmanaged.passRetained(resolver).toOpaque()
        var clientContext = CFHostClientContext(version: 0, info: UnsafeMutableRawPointer(retainedClosure),
                                                retain: nil, release: nil, copyDescription: kCopyNoOperation)

        let hostReference = CFHostCreateWithName(kCFAllocatorDefault, host as CFString).takeUnretainedValue()
        resolver.timer = Timer.scheduledTimer(timeInterval: timeout, target: resolver,
                                              selector: #selector(DNSResolver.onTimeout),
                                              userInfo: hostReference, repeats: false)

        CFHostSetClient(hostReference, callback, &clientContext)
        CFHostScheduleWithRunLoop(hostReference, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        CFHostStartInfoResolution(hostReference, .addresses, nil)
    }

    @objc
    private func onTimeout() {
        defer {
            self.completion?([])

            // Manually release the previously retained self.
            Unmanaged.passUnretained(self).release()
        }

        guard let userInfo = self.timer?.userInfo else {
            return
        }

        let hostReference = unsafeBitCast(userInfo as AnyObject, to: CFHost.self)
        CFHostCancelInfoResolution(hostReference, .addresses)
        CFHostUnscheduleFromRunLoop(hostReference, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        CFHostSetClient(hostReference, nil, nil)
    }
}

// MARK: - sockaddr_storage helpers
extension sockaddr_storage {
    /// Creates a new storage value from a data type that contains the memory layout of a sockaddr_t. This
    /// is used to create sockaddr_storage(s) from some of the CF C functions such as `CFHostGetAddressing`.
    ///
    /// !!! WARNING: This method is unsafe and assumes the memory layout is of `sockaddr_t`. !!!
    ///
    /// - parameter data: The data to be interpreted as sockaddr
    /// - returns: The newly created sockaddr_storage value
    static func from(unsafeDataWithSockAddress data: NSData) -> sockaddr_storage {
        var storage = sockaddr_storage()
        data.getBytes(&storage, length: data.length)
        return storage
    }

    /// Calls a closure with traditional BSD Sockets address parameters.
    ///
    /// - parameter body: A closure to call with `self` referenced appropriately for calling
    ///   BSD Sockets APIs that take an address.
    ///
    /// - throws: Any error thrown by `body`.
    ///
    /// - returns: Any result returned by `body`.
    func withUnsafeAddress<T, U>(_ body: (_ address: UnsafePointer<U>) -> T) -> T {
        var storage = self
        return withUnsafePointer(to: &storage) {
            $0.withMemoryRebound(to: U.self, capacity: 1) { address in body(address) }
        }
    }
}
