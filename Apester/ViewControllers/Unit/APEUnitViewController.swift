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
    
    var apesterUnitView: APEUnitView!
    let configuration = try? APEUnitConfiguration(mediaId: "5e67832958c4d8457106a2ed",
                                                  bundle: Bundle.main, environment: .stage)
   @IBOutlet weak var unitContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preLoad implemntation
        apesterUnitView = APEUnitViewService.shared.unitView()
        
        if apesterUnitView == nil {
            // not preload!
            guard let unitConfig = configuration else { return }
            apesterUnitView = APEUnitView(configuration: unitConfig)
            
        }
        unitContainerView.addSubview(apesterUnitView.unitWebView)
    }

}
