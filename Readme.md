## ApesterKit

[![Platforms](https://img.shields.io/cocoapods/p/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)
[![License](https://img.shields.io/cocoapods/l/ApesterKit.svg)](https://raw.githubusercontent.com/Apester/ApesterKit/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/ApesterKit.svg)](https://cocoapods.org/pods/ApesterKit)

ApesterKit provides a light-weight framework that loads Apester Unit in a webView

- [Requirements](#requirements)
- [Installation](#installation)
- [Implementaion](#implementaion)
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

## Handle Strip Units
### `APEStripService` Implementaion
The APEStripService is a proxy messaging handler between The Apester Units Carousel component (The `StripWebView`) and the selected Apester Unit (The `StoryWebView`), . Follow our step by step guide and setup: 

1 - create a new instance for APEStripService with a channel token and app main bundle:
```
let stripServiceInstance = APEStripService(channelToken: "5890a541a9133e0e000e31aa",
                                           bundle:  Bundle.main)
```

2 - set `APEStripServiceDelegate`, `APEStripServiceDataSource` (optional), so you can handle story unit presentation, show / hide events. 
```
self.stripServiceInstance.delegate = self
self.stripServiceInstance.dataSource = self
```

3 - setup the StripWebView in your `StripViewController` .
```
let stripWebView = self.stripServiceInstance.stripWebView
stripWebView.frame = self.view.bounds
self.view.addSubview(stripWebView)
```
4 - Implement the `APEStripServiceDelegate`, so you can handle Apester Story Unit presentation.

```
extension APEStripViewController: APEStripServiceDelegate {
  func stripComponentIsReady(unitHeight height: CGFloat) {
    // update stripWebView height (optional) 
    // hide loading
  }

  func displayStoryComponent() {
    if self.storyViewController == nil {
      self.storyViewController = APEStripStoryViewController()
      // set the `StoryWebView`
      self.storyViewController!.webView = self.stripServiceInstance.storyWebView
    }
    self.navigationController?.pushViewController(self.storyViewController!, animated: true)
  }

  func hideStoryComponent() {
    self.storyViewController?.navigationController?.popViewController(animated: true)
  }
}
```

5- Implement the `APEStripServiceDataSource` so you can observe the Apester Story Unit show / hide events.
```
extension APEStripViewController: APEStripServiceDataSource {
  var showStoryFunction: String {
    return "console.log('show story');"
  }

  var hideStoryFunction: String {
    return "console.log('hdie story');"
  }
}
```

6 - Create a  `StripStoryViewController` class, so the Apester selected Unit can be displayed.
```
class StripStoryViewController: UIViewController {
  var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.frame = self.view.bounds
    self.view.addSubview(self.webView)
  }
}
```

## Handle Unit Height Updates
### `APEWebViewService` Implementaion

1 - register the app main bundle and the webView, In your viewController  viewDidLoad function:

```
APEWebViewService.shared.register(bundle: Bundle.main, webView: webView, unitHeightHandler: { [weak self] result in
  switch result {
    case .success(let height):
      print(height)
    case .failure(let err):
      print(err)
  }
})
```

2 - pass the device advertising params and get the apester unit height update by calling didStartLoad and didFinishLoad:

• UIWebView Case:

```
extension ViewController: UIWebViewDelegate {
  func webViewDidStartLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }

  func webViewDidFinishLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}
```

• WKWebView Case:

```
extension ViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}
```

Clone the project and Run the ApesterKitDemo App:
```
1 - clone it `git clone git@github.com:Qmerce/ios-sdk.git`.
2 -  run `carthage update`.
3 - select ApesterKitDemo Target.
4 - run the App and enjoy.
```

## License

ApesterKit is released under the MIT license. See [LICENSE](https://github.com/Qmerce/ios-sdk/blob/master/LICENSE) for details.

