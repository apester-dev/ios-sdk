//
//  APEStripViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEStripViewController: UIViewController {

  private var storyViewController: APEStripStoryViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    APEStripService.shared.register(bundle:  Bundle.main, channelToken: "5890a541a9133e0e000e31aa")
    APEStripService.shared.datasource = self
    let storyWebView = APEStripService.shared.storyWebView
    storyWebView.frame = self.view.bounds
    self.view.addSubview(storyWebView)
    let stripWebView = APEStripService.shared.stripWebView
    stripWebView.frame = self.view.bounds
    self.view.addSubview(stripWebView)
  }
}

extension APEStripViewController: APEStripServiceDatasource {
  var showStoryFunction: String {
    self.storyViewController = APEStripStoryViewController()
    self.navigationController?.pushViewController(self.storyViewController!, animated: true)
    return "console.log('show story');"
  }

  var hideStoryFunction: String {
    self.storyViewController?.navigationController?.popViewController(animated: true)
    return "console.log('hdie story');"
  }
}
