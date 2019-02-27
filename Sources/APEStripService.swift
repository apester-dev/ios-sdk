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
  func stroyComponentIsReady()
}

public protocol APEStripServiceDatasource: AnyObject {
  var showStoryFunction: String { get }
  var hideStoryFunction: String { get }
}

open class APEStripService: NSObject {

  private enum State {
    case initial, open, next, off
  }

  public static let shared = APEStripService()

  public weak var datasource: APEStripServiceDatasource?
  public weak var delegate: APEStripServiceDelegate?

  public lazy var stripWebView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
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
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.showStripStory)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.hideStripStory)
    let storyHtmlString = APEBundle.contentsOfFile(APEConfig.Strip.stripStoryFileName)
    if let storyUrl = URL(string: APEConfig.Strip.stripStoryUrlPath) {
      DispatchQueue.main.async {
        webView.load(URLRequest(url: storyUrl))
      }
    }
    return webView
  }()

  private var stripUrlPath: String?
  private var bodyMessage: String?
  private var state: State = .initial
  private var isFresh = true
  private var forceUpdate = false

  private override init() {
    super.init()
    _ = self.storyWebView
  }

  public func register(bundle: Bundle, channelToken: String) {
    let parameters = ["token": channelToken] + APEBundle.bundleInfoPayload(with: bundle)
    self.stripUrlPath = parameters.urlComponents(APEConfig.Strip.stripUrlPath)
    _ = self.stripWebView
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
        if (self.state == .open || self.isFresh), let showStoryFunction = self.datasource?.showStoryFunction {
          self.isFresh = false
          self.forceUpdate = false
          print("showStoryFunction")
          self.storyEvaluateJavaScript(message: showStoryFunction)
        }
      } else if message.name == APEConfig.Strip.hideStripStory {
        if let hideStoryFunction = self.datasource?.hideStoryFunction {
          print("hideStripStory hideStoryFunction")
          self.storyEvaluateJavaScript(message: hideStoryFunction)
        }
      } else if let bodyString = message.body as? String {
        if bodyString.contains(APEConfig.Strip.off) {
          self.state = .off
        } else if bodyString.contains(APEConfig.Strip.initial) {
          print("initial __sendApesterEvent")
          self.state = .initial
          self.storySendApesterEvent(message: bodyString)

        } else if bodyString.contains(APEConfig.Strip.open) {
          if self.state == .initial {
            self.state = .open
            print(bodyString)
            self.storySendApesterEvent(message: bodyString)

          } else if self.state != .open {
            self.state = .initial
            let next = bodyString.replacingOccurrences(of: APEConfig.Strip.open, with: APEConfig.Strip.next)
            self.forceUpdate = true
            self.storySendApesterEvent(message: next)
          }

        } else if bodyString.contains(APEConfig.Strip.next) {
          if self.state == .initial {
            self.state = .open
            let next = bodyString.replacingOccurrences(of: APEConfig.Strip.next, with: APEConfig.Strip.open)
            self.forceUpdate = true
            self.storySendApesterEvent(message: next)

          } else if self.state != .open, self.forceUpdate {
            self.state = .initial
            self.storySendApesterEvent(message: bodyString)

          } else {
            self.state = .next
          }
        } else if bodyString.contains(APEConfig.Strip.loaded) {
          print("stripComponentIsReady")
          self.delegate?.stripComponentIsReady()
        }
      }
    }
  }
}

extension APEStripService: WKNavigationDelegate {
  private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }

  private func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}

  private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
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
