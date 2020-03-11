//
//  ViewController.swift
//  Apester
//
//  Created by Almog Haimovitch on 09/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit
import ApesterKit

class APEUnitViewController: UIViewController {
    
    
    // local story: 5ddeaa945d06ef005f3668e8
    // stg story: 5e67832958c4d8457106a2ed
    
    var apeUnitWebView: APEUnitWebView!
    let configuration = try? APEUnitConfiguration(mediaId: "5ddeaa945d06ef005f3668e8",
                                                  bundle: Bundle.main, environment: .local)
   @IBOutlet weak var unitContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let unitConfig = configuration else { return }
        apeUnitWebView = APEUnitWebView(unitConfig)
        
        let apesterUnit = apeUnitWebView.unitWebView!
        unitContainerView.addSubview(apesterUnit)
    }

}
