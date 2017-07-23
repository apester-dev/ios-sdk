//
//  ViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 19/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

let apesterUnitURL = "https://qmerce.github.io/static-testing-site/articles/injected2/"
//let apesterUnitURL = "http://localhost:3000"
let apesterUnitURLRequest = URLRequest(url: URL(string: apesterUnitURL)!)

#if USE_UIWEBVIEW
  
  class ViewController: UIViewController {
    
    @IBOutlet weak var webViewContainer: UIView!
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
      loadWebView()
    }

    func loadWebView() {
      webView?.loadRequest(apesterUnitURLRequest)
    }
    func reloadWebView() {
      webView?.loadRequest( URLRequest(url: URL(string: "about:blank")!))
      loadWebView()
    }
  }

  // MARK: - UIWebViewDelegate
  extension ViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
      APEWebViewService.shared.didStartLoad(webView: webView)
    }
  }
  
#else // USE_UIWEBVIEW - USE_WKWEBVIEW
  
  class ViewController: UIViewController {

    @IBOutlet var webViewContainer: UIView!
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

    func loadWebView() {
      webView?.load(apesterUnitURLRequest)
    }
  }

  // MARK: - WKWebViewDelegate
  extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      APEWebViewService.shared.didStartLoad(webView: webView)
    }
  }

#endif // USE_UIWEBVIEW

// MARK: - ViewController extension

extension ViewController {

  @IBAction func sendDataToJavaScriptButtonPressed(_ sender: Any) {
    loadWebView()
  }
}
