//
//  APEUIWebViewController.swift
//  ApesterKit
//
//  Created by Hasan Sa on 25/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class APEUIWebViewController: APEViewController {

  @IBOutlet var webView: UIWebView? {
    didSet {
      webView?.delegate = self
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView = UIWebView(frame: webViewContainer.bounds)
    guard let webView = webView else {
      return
    }
    webViewContainer.addSubview(webView)
    APEWebViewService.shared.register(bundle: Bundle.main)
  }
  
  override func loadWebView() -> Bool {
    if let text = textField.text,
      let url = URL(string: text),
      let _ = webView?.loadRequest(URLRequest(url: url)) {
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
extension APEUIWebViewController: UITextFieldDelegate {
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool  {
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return loadWebView()
  }
}

// MARK: - UIWebViewDelegate
extension APEUIWebViewController: UIWebViewDelegate {
  func webViewDidStartLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }
}
