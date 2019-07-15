//
//  APEWebViewViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEWebViewViewController: UIViewController {

  lazy var urlRequest: URLRequest? = {
    let urlString = "http://qmerce.github.io/static-testing-site/articles/streamrail_stage/"
    if let url = URL(string: urlString) {
      return URLRequest(url: url)
    }
    return nil
  }()

  @IBOutlet weak var contentView: UIView!

  private lazy var wkWebView: WKWebView = {
    // Create the web view
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    return webView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    loadWebView()
  }

  private func setupAutoLayout(for webview: UIView) {
    // Auto Layout
    NSLayoutConstraint.activate([
      webview.topAnchor.constraint(equalTo: contentView.topAnchor),
      webview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      webview.widthAnchor.constraint(equalTo: contentView.widthAnchor),
      webview.heightAnchor.constraint(equalTo: contentView.heightAnchor),
      ])
  }

  private func loadWebView() {
    var webview: WKWebView?

    if let request = urlRequest {
      webview = wkWebView
      contentView.addSubview(wkWebView)
      setupAutoLayout(for: wkWebView)
      wkWebView.load(request)
    }
    if let webview = webview {
      APEWebViewService.shared.register(bundle: Bundle.main, webView: webview)
    }

  }
}

extension APEWebViewViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }
}
