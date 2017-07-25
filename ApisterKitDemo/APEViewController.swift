//
//  ViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 19/07/2017.
//  Copyright © 2017 Apester. All rights reserved.
//

import UIKit

class APEViewController: UIViewController {

  @IBOutlet weak var webViewContainer: UIView!
  @IBOutlet var goButton: UIButton!
  @IBOutlet var textField: UITextField!

  func loadWebView() -> Bool {
    return false
  }
  
  func addWebView(_ webView: UIView?) {
    guard let webView = webView else {
      return
    }
    webViewContainer.addSubview(webView)
    webView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: webViewContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 1.0).isActive = true
    NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: webViewContainer, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 1.0).isActive = true
    NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: webViewContainer, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 1.0).isActive = true
    NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: webViewContainer, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 1.0).isActive = true
  }

  @IBAction func goButtonClicked() {}

}
