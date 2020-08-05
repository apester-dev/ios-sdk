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
    
    var apesterUnitView: APEUnitView!

    private var unitParams: APEUnitParams? = UnitConfigurationsFactory.unitsParams.first
    
    @IBOutlet weak var unitContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = UnitConfigurationsFactory.configurations(for: .stage, hideApesterAds: false, gdprString: nil)[0]

        if let unit = unitParams {
            // preLoad implemntation
            apesterUnitView = APEViewService.shared.unitView(for: unit.id)
        }
        
        if apesterUnitView == nil {
            // not preload!
            apesterUnitView = APEUnitView(configuration: configuration)

        }
        
        guard let unitParams = unitParams else { return }

        APEViewService.shared.unitView(for: unitParams.id)?.delegate = self

        apesterUnitView.display(in: unitContainerView, containerViewConroller: self)
        
        apesterUnitView.setConsentString(consentString: "custom gdpr string")
    }
}

extension APEUnitViewController: APEUnitViewDelegate {
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String) {
    }
    
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String) {

    }

    func unitView(_ unitView: APEUnitView, didCompleteAdsForUnit unitId: String) {

    }
    
    func unitView(_ unitView: APEUnitView, didUpdateHeight height: CGFloat) {
        
    }

}
