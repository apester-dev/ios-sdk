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
  func stripComponentIsReady()
  func displayStroyComponent()
  func hideStroyComponent()
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
@available(iOS 10.0, *)
open class APEStripService: NSObject {

  // MARK:- Private Properties
  private var stripUrlPath: String?
  
  private var initialMessage: String?
  private var openUnitMessage: String?

  private var messages: [Int: String] = [:]

  private var isLoaded: Bool = false
  private var isReady: Bool = false {
    didSet {
      guard isReady else { return }
      self.delegate?.stripComponentIsReady()
      if let openUnitMessage = self.openUnitMessage {
        self.storySendApesterEvent(message: openUnitMessage) { _ in
          self.openUnitMessage = nil
          self.delegate?.displayStroyComponent()
        }
      }
    }
  }

  private lazy var _stripWebView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    if let urlPath = self.stripUrlPath, let stripUrl = URL(string: urlPath) {
      webView.load(URLRequest(url: stripUrl))
    }
    self.messages[webView.hash] = ""
    return webView
  }()

  private lazy var _storyWebView: WKWebView  = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.showStripStory)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.hideStripStory)
    if let storyUrl = URL(string: APEConfig.Strip.stripStoryUrlPath) {
      webView.load(URLRequest(url: storyUrl))
    }
    self.messages[webView.hash] = ""
    return webView
  }()

  // MARK:- Public Properties
  public weak var dataSource: APEStripServiceDataSource?
  public weak var delegate: APEStripServiceDelegate?

  public var stripWebView: WKWebView { return _stripWebView }
  public var storyWebView: WKWebView { return _storyWebView }

  // MARK:- Initializer
  public init(channelToken: String, bundle: Bundle) {
    let parameters = ["token": channelToken] + APEBundle.bundleInfoPayload(with: bundle)
    self.stripUrlPath = parameters.urlComponents(APEConfig.Strip.stripUrlPath)
    super.init()
  }
}

@available(iOS 10.0, *)
// MARK:- UserContentController Script Messages Handle
private extension APEStripService {

  func handleUserContentController(message: WKScriptMessage) {
    if message.name == APEConfig.Strip.showStripStory, message.webView == self.storyWebView {
      if let showStoryFunction = self.dataSource?.showStoryFunction {
        self.storyEvaluateJavaScript(message: showStoryFunction)
      }

    } else if message.name == APEConfig.Strip.hideStripStory {
      if let hideStoryFunction = self.dataSource?.hideStoryFunction {
        self.storyEvaluateJavaScript(message: hideStoryFunction)
      }

    } else if let bodyString = message.body as? String {
      if bodyString.contains(APEConfig.Strip.loaded) {
        if let superView = self.stripWebView.superview, self.storyWebView.superview == nil {
          superView.addSubview(self.storyWebView)
        }
        self.isLoaded = true
      } else if bodyString.contains(APEConfig.Strip.isReady) {
        self.isReady = self.isLoaded

      } else if bodyString.contains(APEConfig.Strip.initial) {
        self.initialMessage = bodyString

      } else if bodyString.contains(APEConfig.Strip.open) {
        guard self.isReady else {
          self.openUnitMessage = bodyString
          return
        }
        self.storySendApesterEvent(message: bodyString) { _ in
          self.delegate?.displayStroyComponent()
        }
      } else if bodyString.contains(APEConfig.Strip.next) {
        if self.initialMessage != nil {
          self.initialMessage = nil
        }
      } else if bodyString.contains(APEConfig.Strip.off) {
        self.delegate?.hideStroyComponent()
      }
      // proxy updates
      if message.webView == self.stripWebView {
        if self.messages[self.storyWebView.hash] != bodyString {
          self.storySendApesterEvent(message: bodyString)
        }

      } else if message.webView == self.storyWebView {
        if self.messages[self.stripWebView.hash] != bodyString {
          self.stripSendApesterEvent(message: bodyString)
        }
      }
    }
  }

  func stripSendApesterEvent(message: String, completion: ((Bool) -> Void)? = nil) {
    self.messages[self.stripWebView.hash] = message
    self.stripWebView.evaluateJavaScript("window.__sendApesterEvent(\(message))") { (response, error) in
      completion?(error == nil)
    }
  }

  func storySendApesterEvent(message: String, completion: ((Bool) -> Void)? = nil) {
    self.messages[self.storyWebView.hash] = message
    self.storyWebView.evaluateJavaScript("window.__sendApesterEvent(\(message))") { (response, error) in
      completion?(error == nil)
    }
  }

  func storyEvaluateJavaScript(message: String, completion: ((Bool) -> Void)? = nil) {
    self.storyWebView.evaluateJavaScript(message) { (response, error) in
      completion?(error == nil)
    }
  }
}

@available(iOS 10.0, *)
// MARK:- WKScriptMessageHandler
extension APEStripService: WKScriptMessageHandler {

  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    DispatchQueue.main.async {
      self.handleUserContentController(message: message)
    }
  }
}

@available(iOS 10.0, *)
// MARK:- WKNavigationDelegate
extension APEStripService: WKNavigationDelegate {

  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let initialMessage = self.initialMessage {
      self.storySendApesterEvent(message: initialMessage) { _ in
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
      if #available(iOS 11.0, *) {
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
        cookies.forEach { cookie in
          webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
      }
    }
    decisionHandler(.allow)
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
