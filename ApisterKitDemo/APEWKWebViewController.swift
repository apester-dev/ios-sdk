//
//  APEWKWebViewController.swift
//  ApesterKit
//
//  Created by Hasan Sa on 25/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit

class APEWKWebViewController: APEViewController {

  var webView : WKWebView? {
    didSet {
      webView?.navigationDelegate = self
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView = WKWebView(frame: webViewContainer.bounds)
    guard let webView = webView else {
      return
    }
    webViewContainer.addSubview(webView)
    APEWebViewService.shared.register(bundle: Bundle.main)
  }

  override func loadWebView() -> Bool {
    if let text = textField.text,
      let url = URL(string: text),
      let _ = webView?.load(URLRequest(url: url)) {
      textField.resignFirstResponder()
      return true
    }
    return false
  }
  
  @IBAction override func goButtonClicked() {
    _ = loadWebView()
  }
}

// MARK:- UITextFieldDelegate
extension APEWKWebViewController: UITextFieldDelegate {
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool  {
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return loadWebView()
  }
}

// MARK: - WKWebViewDelegate
extension APEWKWebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }
}
