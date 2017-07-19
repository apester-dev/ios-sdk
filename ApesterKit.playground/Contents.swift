//: Playground - noun: a place where people can play

import ApesterKit
import UIKit
import PlaygroundSupport


class ViewController: UIViewController, UIWebViewDelegate {
  
  var webView: UIWebView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView = UIWebView(frame: self.view.frame)
    self.webView?.delegate = self
    // 1 . register the webView 
    APEWebViewService.shared.register(with: webView!)
    // ...
  }
  
  
  // MARK - UIWebViewDelegate
  
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    return true
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    APEWebViewService.shared.webView(didStartLoad: ViewController.self)
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    APEWebViewService.shared.webView(didFinishLoad: ViewController.self)
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    APEWebViewService.shared.webView(didFailLoad: ViewController.self, failuer: error)
  }
  
}

let vc = ViewController()
vc.view.frame = UIScreen.main.bounds
vc.view.backgroundColor = .red
PlaygroundPage.current.liveView = vc.view
