//
//  APEStripService.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import WebKit

public protocol APEStripServiceStoryDatasource: AnyObject {
  var showStoryFunction: String { get }
  var hideStoryFunction: String { get }
}

open class APEStripService: NSObject {

  public static let shared = APEStripService()

  public weak var datasource: APEStripServiceStoryDatasource?

  public lazy var stripWebView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    let stripHtmlString = APEBundle.contentsOfFile(APEConfig.Strip.stripFileName)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    webView.loadHTMLString(stripHtmlString, baseURL: APEBundle.bundle.bundleURL)
    return webView
  }()

  public lazy var storyWebView: WKWebView  = {
    let webView = WKWebView()
    let storyHtmlString = APEBundle.contentsOfFile(APEConfig.Strip.stripStoryFileName)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.proxy)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.showStripStory)
    webView.configuration.userContentController.add(self, name: APEConfig.Strip.hideStripStory)
    webView.loadHTMLString(storyHtmlString, baseURL: APEBundle.bundle.bundleURL)
    return webView
  }()

  private var token: String?
  private var domain: String?

  private override init() {
    super.init()
    self.config()
  }

  public func register(bundle: Bundle, token: String, domain: String) {
    self.token = token
    self.domain = domain
  }
}

private extension APEStripService {

  func config() {
    _ = self.storyWebView
    _ = self.stripWebView
  }

  func storySendApesterEvent(message: String, completion: ((Bool) -> Void)? = nil) {
    self.storyWebView.evaluateJavaScript("javascript:window.__sendApesterEvent(\(message))") { (response, error) in
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

    if message.name == APEConfig.Strip.showStripStory, let showStoryFunction = self.datasource?.showStoryFunction {
      self.storyEvaluateJavaScript(message: showStoryFunction)

    } else if message.name == APEConfig.Strip.hideStripStory, let hideStoryFunction = self.datasource?.hideStoryFunction {
      self.storyEvaluateJavaScript(message: hideStoryFunction)

    } else if let bodyString = message.body as? String {
      if (bodyString.contains(APEConfig.Strip.initial) || bodyString.contains(APEConfig.Strip.open)) {
        self.storySendApesterEvent(message: bodyString)

      } else if bodyString.contains(APEConfig.Strip.next), let hideStoryFunction = self.datasource?.hideStoryFunction {
        self.storyEvaluateJavaScript(message: hideStoryFunction)
      }
    }
  }
}

extension APEStripService: WKNavigationDelegate {
  private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }

  private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}
