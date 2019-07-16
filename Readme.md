## ApesterKit

[![Platforms](https://img.shields.io/cocoapods/p/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)
[![License](https://img.shields.io/cocoapods/l/ApesterKit.svg)](https://raw.githubusercontent.com/Apester/ApesterKit/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)

ApesterKit provides a light-weight framework that loads Apester Unit in a webView

- [Requirements](#requirements)
- [Implementaion](#channel-strip-webView)
- [Installation](#installation)
- [License](#license)

## Requirements

- iOS 11.0+
- Xcode .0+
 

## Channel Strip WebView
An Apester Unit is a Carousel component for a Channel units with a configurable designs. Follow our guide step by step and setup. Follow our guide step by step and setup:

### `APEStripService` Implementaion:

1 - declare variable of type `APEStripService`:
```
private var channelStripView: APEChannelStripView!
```

2 - initiate a strip configuration `APEStripConfiguration`. config the channel token, shape, size and shadow parameters ....  
```
// set the strip configuration
let config = APEStripConfiguration(channelToken: "5890a541a9133e0e000e31aa", shape: .square, size: .medium, shadow: false, bundle: Bundle.main)
```

3 - initiate the strip service  instance with the parameter value.
```
// create the channel strip view Instance
self.channelStripView = APEChannelStripView(configuration: config)
```
4 - the channel strip in a container view
4.1 - display  (with a container view controller for navigation porposes).

```
// display
self.channelStripView.display(in: self.containerView, containerViewConroller: self)
```

4.2 - hide the channel strip view.

```
// hide
self.stripService.hide()
```


## Installation

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) automates the distribution of Swift code. To use ApesterKit with SPM, add a dependency to your `Package.swift` file:

```swift
let package = Package(
                      dependencies: [
                        .package(url: "https://github.com/Qmerce/ios-sdk.git", from: "2.0.0")
                      ]
)
```

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build ApesterKit 1.3+.

To integrate ApesterKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

pod 'ApesterKit', '~> 1.3'
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
github "Qmerce/ios-sdk" ~> 1.3
```

Then, run the following command:

```bash
$ carthage update --platform iOS --use-submodules
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

Clone the project and Run the ApesterKitDemo App:
```
1 - clone it `git clone git@github.com:Qmerce/ios-sdk.git`.
2 -  run `carthage update`.
3 - select ApesterKitDemo Target.
4 - run the App and enjoy.
```

## License

ApesterKit is released under the MIT license. See [LICENSE](https://github.com/Qmerce/ios-sdk/blob/master/LICENSE) for details.

