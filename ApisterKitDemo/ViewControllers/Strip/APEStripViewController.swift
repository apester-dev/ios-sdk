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

  private var vc: APEStripStoryViewController!

  override func viewDidLoad() {
    super.viewDidLoad()
    APEStripService.shared.register(bundle:  Bundle.main, token: "", domain: "")
    APEStripService.shared.datasource = self
    let stripWebView = APEStripService.shared.stripWebView
    stripWebView.frame = self.view.bounds
    self.view.addSubview(stripWebView)
  }
}

extension APEStripViewController: APEStripServiceStoryDatasource {
  var showStoryFunction: String {
    vc = APEStripStoryViewController()
    self.navigationController?.pushViewController(vc, animated: false)
    return "console.log('show story');"
  }

  var hideStoryFunction: String {
    vc?.navigationController?.popViewController(animated: false)
    return "console.log('hdie story');"
  }
}
