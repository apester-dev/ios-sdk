//
//  ViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 19/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class ViewController: UIViewController {

  @IBOutlet weak var webView: UIWebView! {didSet {
      webView.delegate = self
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    webView.loadHTMLString(self.htmlStringFromFile(with: "sampleHTMLCode"), baseURL: nil)
    APEWebViewService.shared.register(with: webView)
  }

  private func htmlStringFromFile(with name: String) -> String {
    let path = Bundle.main.path(forResource: name, ofType: "html")
    if let result = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8) {
      return result
    }
    return ""
  }
  
  @IBAction func sendDataToJavaScriptButtonPressed(_ sender: Any) {
    _ = canLoadRequest(with: "http://qmerce.github.io/static-testing-site/articles/injected2/")
  }
}

//MARK:-
extension ViewController {
  
  func canLoadRequest(with string: String?) -> Bool {
    if let urlString = string {
      loadRequest(for: urlString)
      return true
    }
    return false
  }
  
  func loadRequest(for urlString: String) {
    let url = URL(string: urlString)
    let request = URLRequest(url: url! as URL)
    webView.loadRequest(request)
  }
}

//MARK:- UIWebViewDelegate
extension ViewController: UIWebViewDelegate {
  
  
  func webViewDidStartLoad(_ webView: UIWebView) {
     APEWebViewService.shared.webView(didStartLoad: self.classForCoder)
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
//    APEWebViewService.shared.webView(didFinishLoad: self.classForCoder)
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    
  }
}

