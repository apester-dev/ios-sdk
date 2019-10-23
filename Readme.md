## ApesterKit

[![Platforms](https://img.shields.io/cocoapods/p/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)
[![License](https://img.shields.io/cocoapods/l/ApesterKit.svg)](https://raw.githubusercontent.com/Apester/ApesterKit/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)

ApesterKit provides a light-weight framework that loads Apester Unit in a webView

- [Requirements](#requirements)
- [Implementation](#apester-strip-view)
- [Installation](#installation)
- [License](#license)

#
## Requirements

- iOS 11.0+
- Xcode 10.2+
 
#
## Apester Strip View
A Carousel component for a channel that contains an Apester units of the media publisher. These units were built with [Apester Platform](https://apester.com), The Carousel component design can be configured and displayed any where.
Follow our guide step by step and setup. Follow our guide step by step and setup:

### Implementaion:

##### 1 - declare variable of type `APEStripView`:
```ruby
## Swift
private var stripView: APEStripView!
```
```ruby
## Objective C
@property (nonatomic, strong) APEStripView *stripView;
```

##### 2 - initiate a strip style configuration `APEStripStyle`. configure the strip view style, i.e shape, size, padding, shadow, title header  and more....
```ruby
## Swift
let header = APEStripHeader(text: "Title", size: 25.0, family: nil, weight: 400, color: .darkText)
let style  = APEStripStyle(shape: .roundSquare, size: .medium, 
                         padding: UIEdgeInsets(top: 5.0, left: 0, bottom: 0, right: 0),
                         shadow: false, textColor: nil, background: nil, header: header)

```
```ruby
## Objective C
APEStripHeader *header =  [[APEStripHeader alloc] initWithText:@"Title" size:25.0 family:nil weight:400 color:[UIColor purpleColor]];
APEStripStyle *style = [[APEStripStyle alloc] initWithShape:APEStripShapeRoundSquare
                                                       size:APEStripSizeMedium
                                                    padding:UIEdgeInsetsMake(10.0, 0, 0, 0)
                                                     shadow:NO  
                                                     textColor:nil
                                                     background:[UIColor whiteColor]
                                                     header:header];

```

##### 3 - initiate a strip configuration `APEStripConfiguration`. set the channel token, style and bundle parameters ....  
```ruby
## Swift
let configuration = try? APEStripConfiguration(channelToken: channelToken,
                                               style: style,
                                               bundle: Bundle.main)
```
```ruby
## Objective C
NSError *error = nil;
APEStripConfiguration *config = [[APEStripConfiguration alloc] initWithChannelToken:channelToken
                                                               style:style
                                                               bundle:[NSBundle mainBundle]
                                                               error:&error];

```
##### 4 - initiate the strip view  instance with the parameter value.
```ruby
## Swift
self.stripView = APEStripView(configuration: config)
```
```ruby
## Objective C
self.stripView = [[APEStripView alloc] initWithConfiguration:config];
```

##### 5 - The channel strip in a container view
###### 5.1 - display  (with a container view controller for navigation porposes).

```ruby
## Swift
stripView?.display(in: self.containerView, containerViewConroller: self)
```
```ruby
## Objective C
[self.stripView displayIn:self.containerView containerViewConroller:self];
```

###### 5.2 - hide the channel strip view.
```ruby
## Swift
self.stripView.hide()
```
```ruby
## Objective C
[self.stripView hide];
```

##### 6 - Implemet The `APEStripViewDelegate` to observe the stripView updates when success, failure or height updates.



#
## Installation

### Swift Package Manager

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

> CocoaPods 1.1.0+ is required to build ApesterKit.

To integrate ApesterKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby

platform :ios, '11.0'

use_frameworks!
pod 'ApesterKit'

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
github 'Qmerce/ios-sdk'
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

