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
    APEStripService.shared.register(bundle:  Bundle.main, token: "5890a541a9133e0e000e31aa")
    APEStripService.shared.datasource = self
    let stripWebView = APEStripService.shared.stripWebView
    stripWebView.frame = self.view.bounds
    self.view.addSubview(stripWebView)
  }
}

extension APEStripViewController: APEStripServiceDatasource {
  var showStoryFunction: String {
    vc = APEStripStoryViewController()
    self.navigationController?.pushViewController(vc, animated: true)
    return "console.log('show story');"
  }

  var hideStoryFunction: String {
    vc?.navigationController?.popViewController(animated: true)
    return "console.log('hdie story');"
  }
}
