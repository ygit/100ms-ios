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
### ios setup
```
fastlane ios setup
```

### ios build_example_app
```
fastlane ios build_example_app
```
Archives & generates iPA for Example App
### ios upload_on_firebase
```
fastlane ios upload_on_firebase
```
Distributes the HMSVideoExample app on Firebase

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
