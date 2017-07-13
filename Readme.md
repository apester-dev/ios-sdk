## ApesterKit

[![Platforms](https://img.shields.io/cocoapods/p/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)
[![License](https://img.shields.io/cocoapods/l/ApesterKit.svg)](https://raw.githubusercontent.com/Apester/ApesterKit/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)

ApesterKit provides a light-weight framework that loads Apester Unit in a webView

- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#documentation)
- [License](#license)

## Requirements

- iOS 8.0+ 
- Xcode .0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build ApesterKit 1.1+.

To integrate ApesterKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

pod 'ApesterKit', '~> 1.1'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ApesterKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Qmerce/ios-sdk" ~> 1.1
```


### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ApesterKit into your project manually.

#### Git Submodules

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add ApesterKit as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/Qmerce/ios-sdk.git
$ git submodule update --init --recursive
```

- Open the new `ApesterKit` folder, and drag the `ApesterKit.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `ApesterKit.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `ApesterKit.xcodeproj` folders each with two different versions of the `ApesterKit.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `ApesterKit.framework`.

- And that's it!

> The `ApesterKit.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

#### Embeded Binaries

- Download the latest release from https://github.com/Qmerce/ios-sdk/releases
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `ApesterKit.framework`.
- And that's it!

## Documentation

ApesterKit [API Documentation](http://htmlpreview.github.io/?https://github.com/Qmerce/ios-sdk/blob/master/docs/index.html)

## License

ApesterKit is released under the MIT license. See [LICENSE](https://github.com/Qmerce/ios-sdk/blob/master/LICENSE) for details.

