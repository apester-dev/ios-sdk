//
//  APEStripStoryViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEStripStoryViewController: UIViewController {
  var webView: WKWebView = APEStripService.shared.storyWebView

  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.frame = self.view.bounds
    self.view.addSubview(self.webView)
  }
}
