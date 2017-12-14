//
//  APEWKWebViewTableViewCell.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEWKWebViewTableViewCell: APEWebViewTableViewCell {
  var didStartLoad = false
  private lazy var webView: WKWebView = {
    // Create the web view
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.scrollView.isScrollEnabled = false
    webView.navigationDelegate = self
    return webView
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupWebContentView(webView: webView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension APEWKWebViewTableViewCell: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    if !didStartLoad {
      didStartLoad = true
      APEWebViewService.shared.didStartLoad(webView: webView)
    }
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}
