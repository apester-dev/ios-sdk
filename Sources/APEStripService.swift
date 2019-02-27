//
//  APEStripService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

public protocol APEStripServiceDelegate: AnyObject {
  func stripComponentIsReady()
  func displayStroyComponent()
  func hideStroyComponent()
}

public protocol APEStripServiceDatasource: AnyObject {
  var showStoryFunction: String { get }
  var hideStoryFunction: String { get }
}

open class APEStripService: NSObject {

  public static let shared = APEStripService()

  public weak var dataSource: APEStripServiceDatasource?
  public weak var delegate: APEStripServiceDelegate?

  public lazy var stripWebView: WKWebView = {
    let webView = WKWebView()
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    if let urlPath = self.stripUrlPath, let stripUrl = URL(string: urlPath) {
      DispatchQueue.main.async {
        webView.load(URLRequest(url: stripUrl))
      }
    }
    return webView
  }()
  
  public lazy var storyWebView: WKWebView  = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.showStripStory)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.hideStripStory)
    webView.contentMode = .scaleToFill
    if let storyUrl = URL(string: APEConfig.Strip.stripStoryUrlPath) {
      DispatchQueue.main.async {
        webView.load(URLRequest(url: storyUrl))
      }
    }
    return webView
  }()

  private var stripUrlPath: String?
  private var message: String?

  private override init() {
    super.init()
  }

  public func register(bundle: Bundle, channelToken: String) {
    let parameters = ["token": channelToken] + APEBundle.bundleInfoPayload(with: bundle)
    self.stripUrlPath = parameters.urlComponents(APEConfig.Strip.stripUrlPath)
  }
}

private extension APEStripService {

  func storySendApesterEvent(message: String, completion: ((Bool) -> Void)? = nil) {
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

extension APEStripService: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    DispatchQueue.main.async {
      if message.name == APEConfig.Strip.showStripStory {
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
          self.delegate?.stripComponentIsReady()

        } else if bodyString.contains(APEConfig.Strip.initial) {
          self.message = bodyString

        } else if bodyString.contains(APEConfig.Strip.open) {
//          if self.message != nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//              self.storySendApesterEvent(message: bodyString) { _ in
//                self.delegate?.displayStroyComponent()
//              }
//            }
//          } else {
            self.storySendApesterEvent(message: bodyString) { _ in
              self.delegate?.displayStroyComponent()
            }
//          }
        } else if bodyString.contains(APEConfig.Strip.next) {
          if self.message != nil {
            self.message = nil
          }
        } else if bodyString.contains(APEConfig.Strip.off) {
          self.delegate?.hideStroyComponent()
        }
      }
    }
  }
}

extension APEStripService: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let initialMessage = self.message {
      self.storySendApesterEvent(message: initialMessage)
    }
  }

  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }
}

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
