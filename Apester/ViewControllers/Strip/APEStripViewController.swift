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

    @IBOutlet weak var containerView1: UIView!
    @IBOutlet weak var containerView2: UIView!

    private var fastStripServiceInstance1: APEStripService!
    private var fastStripServiceInstance2: APEStripService!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set strip params
        let params = APEStripParams(channelToken: "5890a541a9133e0e000e31aa", shape: .roundSquare, size: .medium, shadow: false, bundle: Bundle.main)

        // create the StripService Instance
        fastStripServiceInstance1 = APEStripService(params: params)
        // display the Strip Component
        fastStripServiceInstance1.displayStripComponent(in: containerView1, rootViewController: self)


//        // create the StripService Instance
//        fastStripServiceInstance2 = APEStripService(params: params)
//        // display the Strip Component
//        fastStripServiceInstance2.displayStripComponent(in: containerView2, rootViewController: self)

    }
}

//class APEStripViewControllerOld: UIViewController {
//
//    private var storyViewController: APEStripStoryViewController?
//    private let stripServiceInstance = APEStripService(channelToken: "5890a541a9133e0e000e31aa", bundle:  Bundle.main)
//
//    @IBOutlet weak var containerView: UIView!
//
//    //    private var stripWebView: WKWebView?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupStripComponent()
//        // display loading view
//    }
//}

//private extension APEStripViewControllerOld {

//    func setupStripComponent() {
//        self.stripServiceInstance.dataSource = self
//        self.stripServiceInstance.delegate = self
//        self.stripWebView = self.stripServiceInstance.stripWebView
//        stripWebView!.frame = self.view.bounds
//        self.view.addSubview(stripWebView!)
//    }
//}

//extension APEStripViewControllerOld: APEStripServiceDataSource {
//    var showStoryFunction: String {
//        return "console.log('show story');"
//    }
//
//    var hideStoryFunction: String {
//        return "console.log('hdie story');"
//    }
//}
//
//extension APEStripViewControllerOld: APEStripServiceDelegate {
//    func stripComponentIsReady(unitHeight height: CGFloat) {
//        self.stripWebView?.frame.size.height = height
//        /// hide loading
//        print(#function)
//    }
//
//    func displayStoryComponent() {
//        if self.storyViewController == nil {
//            self.storyViewController = APEStripStoryViewController()
//            self.storyViewController?.webView = self.stripServiceInstance.storyWebView
//        }
//
//        self.navigationController?.pushViewController(self.storyViewController!, animated: true)
//    }
//
//    func hideStoryComponent() {
//        self.storyViewController?.navigationController?.popViewController(animated: true)
//    }
//}
