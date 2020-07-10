fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios lint
```
fastlane ios lint
```
Runs linter
### ios test
```
fastlane ios test
```
Runs tests
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios staging
```
fastlane ios staging
```
Push a new staging build to TestFlight
### ios release
```
fastlane ios release
```
Push a new build ready for App Store release

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
