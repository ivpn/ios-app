# Changelog

All notable changes to this project will be documented in this file.

## 2.9.1 - 2023-06-29  

[NOTE] Removed references to Port Forwarding  

## 2.9.0 - 2023-05-24  

[NEW] New Widget implemented with WidgetKit  
[NEW] Option to prevent a Multi-Hop chain with the same provider  
[NEW] MTU configuration for WireGuard  
[IMPROVED] Upgraded OpenVPN and OpenSSL libraries  
[IMPROVED] Alternative method to obtain diagnostic logs  
[FIXED] Servers mismatch when selecting individual servers  
[FIXED] Unable to change the port when switching from WireGuard to OpenVPN  
[FIXED] Fastest server settings list automatically toggling servers off  
[FIXED] App remains in "disconnecting" state when using Network Protection  
[FIXED] Server latency not displayed after logging in  
[NOTE] Removed support for iOS 12 and 13  

## 2.8.0 - 2023-01-30  

[NEW] Favorite servers  
[IMPROVED] Option to search and sort in the fastest server configuration list  

## 2.7.1 - 2022-12-08  

[IMPROVED] Support for Split View and Slide Over mode on iPadOS  
[IMPROVED] Upgraded app diagnostic logs  
[FIXED] Crash on app launch caused by Ping service  
[FIXED] Montreal location not showing all available hosts  
[FIXED] Minor bug fixes  

## 2.7.0 - 2022-11-23  

[NEW] Ability to connect to a specific host in a location  
[NEW] Support for custom ports  
[IMPROVED] Warning about existing VPN connection(s) when downgrading subscription plan  
[FIXED] IPv6 connection information not displayed on iOS 16+ devices  
[FIXED] Port number displayed in the settings when MultiHop is enabled  

## 2.6.3 - 2022-05-17  

[IMPROVED] Option to select UDP or TCP when using OpenVPN MultiHop  
[IMPROVED] Search servers by country code  
[IMPROVED] VoiceOver (Accessibility) for the home screen  
[FIXED] Log out issue on iPadOS  
[FIXED] Empty OpenVPN servers list  

## 2.6.2 - 2022-03-29  

[NEW] Hide sensitive UI with privacy overlay when entering background  
[IMPROVED] Use Universal Links when connecting or disconnecting from the widget  
[IMPROVED] Use WKWebView instead SFSafariViewController to improve security  
[IMPROVED] Use more restricted access level for Keychain data  
[FIXED] In some cases session is removed after the iOS upgrade  

## 2.6.1 - 2021-12-16  

[NEW] Shortcuts to enable/disable AntiTracker and Custom DNS  
[IMPROVED] New implementation for OpenVPN Multi-Hop  
[IMPROVED] Improved VoiceOver (Accessibility) for the main screen  
[IMPROVED] Minor UI improvements  
[IMPROVED] OpenVPN and OpenSSL libraries upgraded to the latest version  
[FIXED] Not possible to set DNS over HTTPS/TLS when AntiTracker is enabled  

## 2.5.0 - 2021-11-10  

[NEW] Multi-Hop for WireGuard protocol  
[NEW] Native iOS Kill Switch to block all traffic when VPN tunnel is dropped or unavailable  
[NEW] Keep user settings on log out with an option to clear settings  
[NEW] WireGuard diagnostic logs  
[IMPROVED] Migrate to WireGuardKit framework  
[IMPROVED] Upgrade WireGuard to the latest version  
[FIXED] Current WiFi name not available, fixed for iOS 15.1+ devices  
[FIXED] IPV4/IPV6 tabs displayed in connection info when there is no internet connection  

## 2.4.4 - 2021-09-11  

[FIXED] Not able to connect to VPN for some users  

## 2.4.3 - 2021-09-10  

[IMPROVED] Small UX improvements for the control panel  
[FIXED] Connect to a random host not working with OpenVPN  
[FIXED] Incorrect map position when connected to IVPN server with a custom VPN profile  

## 2.4.2 - 2021-07-13  

[IMPROVED] Added IPv6 connection info to the Today Widget  
[FIXED] WireGuard not connecting on iOS 15 Beta  

## 2.4.1 - 2021-06-29  

[NEW] IPv6 inside WireGuard tunnel  
[NEW] IPv6 connection info  
[IMPROVED] WireGuard upgraded to the latest version  
[IMPROVED] Removed "Disconnect VPN" prompt when changing VPN configuration  
[FIXED] Missing expired subscription alert  

## 2.3.1 - 2021-04-01  

[IMPROVED] Support for custom DoH URL input format  
[FIXED] Location mismatch issue  

## 2.3.0 - 2021-03-18  

[NEW] Configure custom DNS over HTTPS  
[NEW] Application icon  
[IMPROVED] WireGuard is now the default protocol  
[IMPROVED] OpenVPN and OpenSSL libraries upgraded to the latest version  
[FIXED] Incorrect subscription expiration alert  

## 2.2.0 - 2021-02-18  

[NEW] Load balancer for IKEv2 and OpenVPN  
[IMPROVED] WireGuard upgraded to the latest version  
[IMPROVED] Security enhancements  
[FIXED] Small UI bugs on the main screen  
[FIXED] Server mismatch when device recovers from losing internet connection  

## 2.1.0 - 2021-01-28  

[NEW] Updated Privacy Policy and Terms of Service  
[NEW] Certificate pinning to prevent man-in-the-middle attacks  
[NEW] Connect IKEv2 and OpenVPN using the IP address instead of DNS hostname  
[NEW] Support two-factor authentication for login  
[NEW] Support captcha to mitigate attacks  
[FIXED] VPN toggle in a disconnected state when connecting with IKEv2 for the first time  
[FIXED] Disconnect VPN shortcut not working always  
[FIXED] Minor UI issues on iPad devices  

## 2.0.4 - 2020-12-18  

[IMPROVED] App memory performance  
[FIXED] Sometimes app failed to disconnect from a trusted network   

## 2.0.3 - 2020-11-05  

[IMPROVED] Optimised connection info on the control panel  
[IMPROVED] AntiTracker hardcore mode indicator on the control panel  
[IMPROVED] App memory performance  
[FIXED] App does not reconnect to fastest server without ping indicators  
[FIXED] Last server selected as fastest server without ping indicators  
[FIXED] Sometimes app fails to reconnect to fastest server  
[FIXED] Sometimes app disconnects from VPN when switching to fastest server  
[FIXED] App connects to another random server when trying to disconnect from an untrusted network  

## 2.0.2 - 2020-10-08  

[IMPROVED] Minor improvements on the map  
[FIXED] Selecting the fastest server ignores user's configuration  
[FIXED] App crash caused by servers ping indicators  
[FIXED] UI fixes for 4" display iPhone devices (5, 5s, 5c, SE)  

## 2.0.1 - 2020-09-23  

[FIXED] Incorrect subscription expired warning  
[FIXED] App crash when changing screen orientation on QR scanner without camera permission  
[FIXED] Minor UI issues on the main screen  
[FIXED] Today widget not updating UI state on iOS 14  

## 2.0.0 - 2020-09-08  

[NEW] New design  
[NEW] Interactive map  
[NEW] Switch servers, MultiHop, protocols and toggle AntiTracker directly on the main screen  
[NEW] Dedicated account screen  
[IMPROVED] Search and sort on the servers list  

## 2.0.0 - [Unreleased, Public beta]  

[NEW] Redesigned UI  
[NEW] Interactive map  
[NEW] Control panel  
[NEW] Dedicated account screen  
[IMPROVED] Search and sort on the servers list  

Feedback and support:  
beta@ivpn.net  

## 1.19.1 - 2020-07-01

[FIXED] App crashing on iOS 12 devices

## 1.19.0 - 2020-06-30

[NEW] Signup without email  
[NEW] Load balancer for WireGuard  
[IMPROVED] Updated CA certificate for OpenVPN  
[IMPROVED] OpenVPN and OpenSSL libraries upgraded to the latest version  
[IMPROVED] WireGuard upgraded to the latest version  
[IMPROVED] Removed WireGuard beta warning  
[FIXED] Account status not updated for suspended accounts  
[FIXED] Today widget is now available on all iOS 12+ devices  

## 1.18.1 - 2020-03-04

[NEW] Today widget  
[NEW] Option to disable VPN keep-alive for improved battery performance  
[FIXED] Renew suspended or cancelled subscription  

## 1.17.1 - 2019-12-20

[IMPROVED] Web URLs are now opened in standard interface for web content  
[FIXED] App crash that occasionally happens on app launch

## 1.17.0 - 2019-12-12

[NEW] IKEv2  
[IMPROVED] Updated login screen  
[IMPROVED] Ping time indicators performance and reliability  

## 1.16.0 - 2019-12-04

[NEW] Updated subscription plans  
[NEW] Auto-renewable subscriptions  
[NEW] Bypass DNS blocks to IVPN API  
[IMPROVED] Login session management  
[FIXED] App crash that occasionally happens when processing In-App Purchases  
[FIXED] On iOS 13 app displays "Mobile data" when connected to WiFi  

## 1.15.1 - 2019-10-08

[FIXED] Crash when trying to log in without internet connection  

## 1.15.0 - 2019-10-07

[NEW] Support for Dark Mode in iOS 13  

## 1.14.3 - 2019-08-02

[FIXED] Location issue when changing servers, while connected to VPN using Network Protection  

## 1.14.2 - 2019-07-26

[NEW] Added new 1194 UDP port for OpenVPN and WireGuard protocols  
[IMPROVED] Swipe to remove saved network in Network Protection WiFi networks list  
[FIXED] DNS issue with Multi-Hop connection when AntiTracker enabled  

## 1.14.1 - 2019-07-18

[FIXED] Authentication issue for some users  

## 1.14.0 - 2019-07-10

[IMPROVED] New implementation for OpenVPN protocol  
[FIXED] OpenVPN connection issue when switching between WiFi and mobile network  
[FIXED] OpenVPN connection issue when a device wakes up from sleep  

## 1.13.1 - 2019-06-28

[FIXED] Crash in the WireGuard network extension  

## 1.13.0 - 2019-06-11

[NEW] AntiTracker: block ads, malicious websites, and third-party trackers  
[NEW] Custom DNS: specify DNS server when connected to VPN  
[NEW] Automatic WireGuard key regeneration  

## 1.12.0 - 2019-06-05

[NEW] Siri Shortcuts support for Connect and Disconnect actions  
[NEW] Skip login when authentication server is unreachable  
[FIXED] Unable to switch to the Fastest server when Network Protection is enabled  

## 1.11.3 - 2019-05-28

[FIXED] VPN not reconnected in some cases when using IPSec and Network Protection  
[FIXED] VPN not reconnected to the fastest server when opening the app with VPN connected  
[FIXED] VPN automatically connected in some cases when disconnected from a trusted network  
[FIXED] Wrong fastest server displayed after changing protocol and relaunching the app  

## 1.11.1 - 2019-03-29

[FIXED] Ping indicators issue when VPN is connected  
[FIXED] Sometimes IPSec VPN connects again when disconnected  
[FIXED] Issue with disconnecting VPN when changing the protocol in settings  

## 1.11.0 - 2019-03-24

[NEW] Display public IP and geolocation information  
[NEW] Fastest server configuration  
[IMPROVED] Performance upgrade for ping indicators in the servers list  
[FIXED] App sometimes becomes unresponsive when connecting and disconnecting VPN multiple times  
[FIXED] App crashing with network protection is enabled and the device is without an internet connection  
[FIXED] Authentication error when trying to connect to IPSec VPN when the user previously denied adding VPN configuration  

## 1.10.0 - 2019-02-20

[NEW] Fastest Server: select server with the lowest latency automatically  
[FIXED] All user preferences are cleared when reinstalling the app  

## 1.9.1 - 2019-02-06

[FIXED] Location-related issue with IPSec protocol  

## 1.9.0 - 2019-02-01

[NEW] Network Protection: configure how IVPN will behave on connection to WiFi or mobile networks  
[FIXED] Location-related issue with multi-hop connections  

## 1.8.1 - 2019-01-18

[IMPROVED] Updated WireGuard library  
[FIXED] Resolved issue with reconnecting WireGuard tunnel when switching between WiFi and mobile networks  

## 1.8.0 - 2019-01-16

[NEW] Home screen quick actions for connecting and disconnecting VPN  
[IMPROVED] Small UI improvements  
[FIXED] Crash when accessing "Login" in the signup screen  
[FIXED] Added missing validation messages on the signup screen  
[FIXED] Connection problem when enabling Multi-Hop for the first time  
[FIXED] Resolved some UI issues on the iPhone  

## 1.7.0 - 2018-12-11

[NEW] WireGuard protocol  

## 1.6.1 - 2018-12-05

[NEW] Change server without disconnecting  

## 1.5.1 - 2018-11-07

[FIXED] When logs are enabled, the OpenVPN tunnel has problem reconnecting  
[FIXED] Authentication problem when using a password manager  
[FIXED] Some minor UI fixes  

## 1.5.0 - 2018-10-20

[NEW] Multi-Hop connection  
[NEW] OpenVPN logs for troubleshooting  
[FIXED] Disabled selecting different server and protocol when connected to VPN  

## 1.4.1 - 2018-10-04

[IMPROVED] Accessibility features for people who use VoiceOver  
[FIXED] UI issues when using the app in landscape mode on iPhone  
[FIXED] Issue with selecting a new server  

## 1.4 - 2018-08-03

[NEW] Added support for OpenVPN protocol  

## 1.3 - 2018-07-11

[IMPROVED] iPhone X screen support added  

## 1.2 - 2017-02-01
