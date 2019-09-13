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

    @IBOutlet weak var containerView: UIView!

    private var stripView: APEStripView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set strip params
        let configuration = APEStripConfiguration(channelToken: "5890a541a9133e0e000e31aa",
                                                  shape: .roundSquare,
                                                  size: .medium,
                                                  shadow: false,
                                                  bundle: Bundle.main)

        // create the StripService Instance
        stripView = APEStripView(configuration: configuration)
        // display the Strip Component
        stripView.display(in: self.containerView, containerViewConroller: self)
    }
}
