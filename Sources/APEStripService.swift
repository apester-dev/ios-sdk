//
//  APEStripService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

/// Handling The Apester Story Unit presentation
public protocol APEStripServiceDelegate: AnyObject {
  func stripComponentIsReady(unitHeight height: CGFloat)
  func displayStoryComponent()
  func hideStoryComponent()
}

/// Observing The Apester Story Unit show / hide events.
public protocol APEStripServiceDataSource: AnyObject {
  var showStoryFunction: String { get }
  var hideStoryFunction: String { get }
}

/// A Proxy Messaging Handler
///
/// Between The Apester Units Carousel component (The `StripWebView`)
/// And the selected Apester Unit (The `StoryWebView`)
@available(iOS 11.0, *)
open class APEStripService: NSObject {

  // MARK:- Private Properties
  private var stripUrlPath: String?
  
  private var initialMessage: String?
  private var openUnitMessage: String?

  private var messagesTracker = APEStripServiceEventsTracker()

  private var stripLoaded = (isLoaded: false, height: CGFloat(0))

  private var storyisReady: Bool = false {
    didSet {
      guard storyisReady else { return }
      // update delegate
      self.delegate?.stripComponentIsReady(unitHeight: self.stripLoaded.height)
      // send openUnitMessage if needed
      if let openUnitMessage = self.openUnitMessage {
        self.messagesTracker.sendApesterEvent(message: openUnitMessage, to: storyWebView) { _ in
          self.openUnitMessage = nil
          self.delegate?.displayStoryComponent()
        }
      }
    }
  }

  private lazy var _stripWebView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
    webView.configuration.userContentController.register(to: [APEConfig.Strip.proxy], delegate: self)
    if let urlPath = self.stripUrlPath, let stripUrl = URL(string: urlPath) {
      webView.load(URLRequest(url: stripUrl))
    }
    return webView
  }()

  private lazy var _storyWebView: WKWebView  = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
    webView.configuration.userContentController
      .register(to: [APEConfig.Strip.proxy,
                     APEConfig.Strip.showStripStory,
                     APEConfig.Strip.hideStripStory],
                delegate: self)
    if let storyUrl = URL(string: APEConfig.Strip.stripStoryUrlPath) {
      webView.load(URLRequest(url: storyUrl))
    }
    return webView
  }()

  // MARK:- Public Properties
  public weak var dataSource: APEStripServiceDataSource?
  public weak var delegate: APEStripServiceDelegate?

  public var stripWebView: WKWebView { return _stripWebView }
  public var storyWebView: WKWebView { return _storyWebView }

  // MARK:- Initializer
  public init(channelToken: String, bundle: Bundle) {
    super.init()
    let parameters = ["token": channelToken] + APEBundle.bundleInfoPayload(with: bundle)
    self.stripUrlPath = parameters.urlComponents(APEConfig.Strip.stripUrlPath)
  }

  deinit {
    self.stripWebView.configuration.userContentController
      .unregister(from: [APEConfig.Strip.proxy])

    self.storyWebView.configuration.userContentController
      .unregister(from: [APEConfig.Strip.proxy,
                         APEConfig.Strip.showStripStory,
                         APEConfig.Strip.hideStripStory])
  }
}

@available(iOS 11.0, *)
// MARK:- UserContentController Script Messages Handle
private extension APEStripService {

  func handleUserContentController(message: WKScriptMessage) {
    if message.name == APEConfig.Strip.showStripStory {
      if let showStoryFunction = self.dataSource?.showStoryFunction {
        self.messagesTracker.evaluateJavaScript(message: showStoryFunction,
                                                to: self.storyWebView)
      }

    } else if message.name == APEConfig.Strip.hideStripStory {
      if let hideStoryFunction = self.dataSource?.hideStoryFunction {
        self.messagesTracker.evaluateJavaScript(message: hideStoryFunction,
                                                to: self.storyWebView)
      }

    } else if let bodyString = message.body as? String {
      // handle stripWebView events
      if message.webView == stripWebView {
        if bodyString.contains(APEConfig.Strip.loaded) {
          if let superView = stripWebView.superview, storyWebView.superview == nil {
            superView.addSubview(storyWebView)
          }
          var stripIsLoaded = (isLoaded: true, height: CGFloat(0))
          // get unit height
          if let dictioanry = bodyString.dictionary,
            let heightString = dictioanry[APEConfig.Strip.stripHeight] as? String,
            let height = CGFloat(string: heightString) {
            let adjustedContentInsets = self._stripWebView.scrollView.adjustedContentInset.bottom + self._stripWebView.scrollView.adjustedContentInset.top
            stripIsLoaded.height += height + adjustedContentInsets
          }
          self.stripLoaded = stripIsLoaded

        } else if bodyString.contains(APEConfig.Strip.initial) {
          self.initialMessage = bodyString

        } else if bodyString.contains(APEConfig.Strip.open) {
          guard self.storyisReady else {
            self.openUnitMessage = bodyString
            return
          }
          self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView) { _ in
            self.delegate?.displayStoryComponent()
          }
        }
        // proxy updates
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: storyWebView) {
          self.messagesTracker.sendApesterEvent(message: bodyString, to: storyWebView)
        }

        // handle storyWebView events
      } else if message.webView == storyWebView {
        if bodyString.contains(APEConfig.Strip.isReady) {
          self.storyisReady = self.stripLoaded.isLoaded

        } else if bodyString.contains(APEConfig.Strip.next) {
          if self.initialMessage != nil {
            self.initialMessage = nil
          }

        } else if bodyString.contains(APEConfig.Strip.off) {
          self.delegate?.hideStoryComponent()
        }
        // proxy updates
        if self.messagesTracker.canSendApesterEvent(message: bodyString, to: stripWebView) {
          self.messagesTracker.sendApesterEvent(message: bodyString, to: stripWebView)
        }
      }
    }
  }
}

@available(iOS 11.0, *)
// MARK:- WKScriptMessageHandler
extension APEStripService: WKScriptMessageHandler {

  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    DispatchQueue.main.async {
      self.handleUserContentController(message: message)
    }
  }
}

@available(iOS 11.0, *)
// MARK:- WKNavigationDelegate
extension APEStripService: WKNavigationDelegate {

  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let initialMessage = self.initialMessage {
      self.messagesTracker.sendApesterEvent(message: initialMessage, to: self.storyWebView) { _ in
        self.initialMessage = nil
      }
    }
  }

  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }

  public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    guard let response = navigationResponse.response as? HTTPURLResponse,
      let url = navigationResponse.response.url else {
        decisionHandler(.cancel)
        return
    }

    if let headerFields = response.allHeaderFields as? [String: String] {
      let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
      cookies.forEach { cookie in
        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
      }
    }
    decisionHandler(.allow)
  }
}

// MARK:- APEScriptMessageHandler Wrapper
private class APEScriptMessageHandler : NSObject, WKScriptMessageHandler {

  weak var delegate : WKScriptMessageHandler?

  init(delegate: WKScriptMessageHandler) {
    self.delegate = delegate
    super.init()
  }

  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    self.delegate?.userContentController(userContentController, didReceive: message)
  }
}

// MARK:- APEStripServiceEventsTracker
private class APEStripServiceEventsTracker {

  private var messages: [Int: String] = [:]

  func canSendApesterEvent(message: String, to webView: WKWebView) -> Bool {
    return self.messages[webView.hash] != message
  }

  func sendApesterEvent(message: String, to webView: WKWebView, completion: ((Bool) -> Void)? = nil) {
    self.messages[webView.hash] = message
    webView.evaluateJavaScript("window.__sendApesterEvent(\(message))") { (response, error) in
      completion?(error == nil)
    }
  }

  func evaluateJavaScript(message: String, to webView: WKWebView, completion: ((Bool) -> Void)? = nil) {
    webView.evaluateJavaScript(message) { (response, error) in
      completion?(error == nil)
    }
  }
}

// MARK:- Private WKUserContentController Extension
private extension WKUserContentController {

  func register(to scriptMessages: [String], delegate: WKScriptMessageHandler) {
    scriptMessages.forEach({
      self.add(APEScriptMessageHandler(delegate: delegate), name: $0)
    })
  }

  func unregister(from scriptMessages: [String]) {
    scriptMessages.forEach({
      self.removeScriptMessageHandler(forName: $0)
    })
  }

}

// MARK:- Private Dictionary Extension
private extension Dictionary {

  func urlComponents(_ urlPath: String) -> String? {
    var components = URLComponents(string: urlPath)
    components?.queryItems = self.compactMap { (arg) in
      guard let key = arg.key as? String, let value = arg.value as? String else {
        return nil
      }
      return URLQueryItem(name: key, value: value)
    }
    return components?.url?.absoluteString
  }

  static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach { result[$0] = $1 }
    return result
  }
}

// MARK:- Private String
private  extension String {
  var dictionary: [String: Any]? {
    if let data = self.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}

// MARK: Private CGloat
private extension CGFloat {

  init?(string: String) {
    guard let number = NumberFormatter().number(from: string) else {
      return nil
    }
    self.init(number.floatValue)
  }
}
