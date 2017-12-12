//
//  APEViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 12/12/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEViewController: UIViewController {

  lazy var urlRequest: URLRequest? = {
    let urlString = "http://qmerce.github.io/static-testing-site/articles/streamrail_stage/"
    if let url = URL(string: urlString) {
      return URLRequest(url: url)
    }
    return nil
  }()

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var segmentControl: UISegmentedControl!

  private lazy var uiWebView: UIWebView = {
    // Create the web view
    let webView = UIWebView(frame: .zero)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.delegate = self
    return webView
  }()

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
    var webview: APEWebViewProtocol?

    if segmentControl.selectedSegmentIndex == 0, let request = urlRequest {
      webview = uiWebView
      wkWebView.removeFromSuperview()
      contentView.addSubview(uiWebView)
      setupAutoLayout(for: uiWebView)
      uiWebView.loadRequest(request)
	
    } else if segmentControl.selectedSegmentIndex == 1, let request = urlRequest {
      webview = wkWebView
      uiWebView.removeFromSuperview()
      contentView.addSubview(wkWebView)
      setupAutoLayout(for: wkWebView)
      wkWebView.load(request)
    }
    if let webview = webview {
      APEWebViewService.shared.register(bundle: Bundle.main, webView: webview)
    }

  }

  // MARK: - ACTIONS

  @IBAction func onSegmentControlChange(_ sender: UISegmentedControl) {
    loadWebView()
  }

}

extension APEViewController: UIWebViewDelegate {
  func webViewDidStartLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }

  func webViewDidFinishLoad(_ webView: UIWebView) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}

extension APEViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    APEWebViewService.shared.didStartLoad(webView: webView)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    APEWebViewService.shared.didFinishLoad(webView: webView)
  }
}
