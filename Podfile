platform :ios, '12.0'
use_frameworks!

target 'IVPNClient' do
    pod 'TunnelKit', '~> 3.3.1'
    pod 'KeychainAccess', '~> 3.2.0'
    pod 'SwiftyStoreKit', '~> 0.15.0'
    pod 'JGProgressHUD', '~> 2.0.3'
    pod 'ActiveLabel', '~> 1.1.0'
    pod 'ReachabilitySwift', '~> 5.0.0'
    pod 'FloatingPanel', '~> 1.7.2'
    pod 'SnapKit', '~> 5.0.1'
end

target 'openvpn-tunnel-provider' do
    pod 'TunnelKit', '~> 3.3.1'
    pod 'KeychainAccess', '~> 3.2.0'
end

target 'wireguard-tunnel-provider' do
    pod 'KeychainAccess', '~> 3.2.0'
end

target 'today-extension' do
    pod 'KeychainAccess', '~> 3.2.0'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
end
