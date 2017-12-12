//
//  ViewController.swift
//  ApesterTest
//
//  Created by Heiber, Florian on 23.08.2017.
//  Copyright © 2017 SPORT1 Online GmbH. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEViewController: UIViewController {

  var heightAnchor: NSLayoutConstraint?

  // MARK: - LIFE CYCLE

  override func loadView() {
    super.loadView()
    setupWebview()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Register to ApesterKit
    APEWebViewService.shared.register(bundle: Bundle.main, webView: webView, unitHeightHandler: { [weak self] result in
      switch result {
      case .success(let height):
          self?.heightAnchor?.constant = height
      case .failure(let err):
        print(err)
      }
    })

    loadApesterUnit()
  }

  // MARK: - PRIVATE

  private var webView: WKWebView!
//  private var webView: UIWebView!

  private func setupWebview() {
    // Create the web view
//    webView = {
//      let webview = UIWebView(frame: .zero)
//      webview.delegate = self
//      return webview
//    }()

    webView = {
      let webview = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
      webview.navigationDelegate = self
      return webview
    }()

    //
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)

    // Auto Layout
    let heightAnchor = webView.heightAnchor.constraint(equalToConstant: 400)
    NSLayoutConstraint.activate([
      webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
      webView.widthAnchor.constraint(equalTo: view.widthAnchor),
      heightAnchor
      ])
    self.heightAnchor = heightAnchor
  }

  private func loadApesterUnit() {
    // Do any additional setup after loading the view, typically from a nib.
    let mediaId = "5a2ebfc283629700019469e7"
    guard let sourceString = Mustache.render("Apester", data: ["mediaId": mediaId as AnyObject]) else { return }
    webView.loadHTMLString(sourceString, baseURL: URL(string: "file://"))
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
