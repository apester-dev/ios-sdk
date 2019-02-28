//
//  APEUIWebViewTableViewCell.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class APEUIWebViewTableViewCell: APEWebViewTableViewCell {
  
  private lazy var webView: UIWebView = {
    // Create the web view
    let webView = UIWebView(frame: .zero)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.scrollView.isScrollEnabled = false
    webView.delegate = self
    return webView
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupWebContentView(webView: webView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


extension APEUIWebViewTableViewCell: UIWebViewDelegate {
  func webViewDidStartLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }

  func webViewDidFinishLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}
