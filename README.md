# IVPN for iOS

![CI](https://github.com/ivpn/ios-app/workflows/CI/badge.svg)
![SwiftLint](https://github.com/ivpn/ios-app/workflows/SwiftLint/badge.svg)
![Lint Code Base](https://github.com/ivpn/ios-app/workflows/Lint%20Code%20Base/badge.svg)

**IVPN for iOS** is a native app built using Swift language. Some of the features include: multiple protocols (IKEv2, OpenVPN, WireGuard), Kill-switch, Multi-Hop, Trusted Networks, AntiTracker, Custom DNS, Dark mode and more.  
IVPN iOS app is distributed on the [App Store](https://apps.apple.com/us/app/ivpn-serious-privacy-protection/id1193122683?mt=8).  

* [About this Repo](#about-repo)
* [Installation](#installation)
* [Testing](#testing)
* [Deployment](#deployment)
* [Versioning](#versioning)
* [Contributing](#contributing)
* [Security Policy](#security)
* [License](#license)
* [Authors](#Authors)
* [Acknowledgements](#acknowledgements)

<a name="about-repo"></a>
## About this Repo

This is the official Git repo of the [IVPN for iOS project](https://github.com/ivpn/ios-app).

<a name="installation"></a>
## Installation

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+
- fastlane 2.178.0+
- Go 1.16+

### Dev dependencies

Project dev dependencies:  

* [fastlane](https://fastlane.tools)  
* [SwiftLint](https://github.com/realm/SwiftLint)  
* [Go](https://golang.org)  

Install fastlane, SwiftLint and Go:  

```sh
$ brew install fastlane swiftlint go
```

### Dependencies

Dependencies are installed with [Swift Package Manager](https://swift.org/package-manager/).

Project dependencies:  

* [WireGuardKit](https://github.com/WireGuard/wireguard-apple)  
* [TunnelKit](https://github.com/passepartoutvpn/tunnelkit)  
* [SnapKit](https://github.com/SnapKit/SnapKit)  
* [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)  
* [SwiftyStoreKit](https://github.com/bizz84/SwiftyStoreKit)  
* [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)  
* [ActiveLabel](https://github.com/optonaut/ActiveLabel.swift)  
* [ReachabilitySwift](https://github.com/ashleymills/Reachability.swift)  
* [FloatingPanel](https://github.com/scenee/FloatingPanel)  

### Xcode build configurations

There are different build configurations: Staging and Release. 

Rename and populate `.xcconfig` files: 

```sh
$ cp IVPNClient/Config/staging.template.xcconfig IVPNClient/Config/staging.xcconfig  
$ cp IVPNClient/Config/release.template.xcconfig IVPNClient/Config/release.xcconfig  
$ cp wireguard-tunnel-provider/Config/wg-staging.template.xcconfig wireguard-tunnel-provider/Config/wg-staging.xcconfig   
$ cp wireguard-tunnel-provider/Config/wg-release.template.xcconfig wireguard-tunnel-provider/Config/wg-release.xcconfig  
$ cp IVPNWidget/Config/widget-staging.template.xcconfig IVPNWidget/Config/widget-staging.xcconfig  
$ cp IVPNWidget/Config/widget-release.template.xcconfig IVPNWidget/Config/widget-release.xcconfig   
```

### OpenVPN configuration

Rename and populate `OpenVPNConf.swift` file: 

```sh
$ cp IVPNClient/Config/OpenVPNConf.template.swift IVPNClient/Config/OpenVPNConf.swift
```

### Fastlane configuration

Rename and populate `Appfile` files: 

```sh
$ cp fastlane/Appfile.template fastlane/Appfile
```

<a name="testing"></a>
## Testing

Run code linter using fastlane:  

```sh
$ fastlane lint
```

Run tests using fastlane:  

```sh
$ fastlane test
```

Alternatively, run tests using xcodebuild:  

```sh
$ xcodebuild test -scheme IVPNClient -destination 'platform=iOS Simulator,name=iPhone 14'
```

<a name="deployment"></a>
## Deployment

To build and deploy beta build to TestFlight:  

```sh
$ fastlane beta
```

To build and deploy staging build to TestFlight:  

```sh
$ fastlane staging
```

To build and deploy App Store release build to TestFlight:  

```sh
$ fastlane release
```

<a name="versioning"></a>
## Versioning

Project is using [Semantic Versioning (SemVer)](https://semver.org) for creating release versions.

SemVer is a 3-component system in the format of `x.y.z` where:

`x` stands for a **major** version  
`y` stands for a **minor** version  
`z` stands for a **patch**

So we have: `Major.Minor.Patch` 

<a name="contributing"></a>
## Contributing

If you are interested in contributing to IVPN for iOS project, please read our [Contributing Guidelines](/.github/CONTRIBUTING.md).

<a name="security"></a>
## Security Policy

If you want to report a security problem, please read our [Security Policy](/.github/SECURITY.md).

<a name="license"></a>
## License

This project is licensed under the GPLv3 - see the [License](/LICENSE.md) file for details.

<a name="authors"></a>
## Authors

See the [Authors](/AUTHORS) file for the list of contributors who participated in this project.

<a name="acknowledgements"></a>
## Acknowledgements

See the [Acknowledgements](/ACKNOWLEDGEMENTS.md) file for the list of third party libraries used in this project.