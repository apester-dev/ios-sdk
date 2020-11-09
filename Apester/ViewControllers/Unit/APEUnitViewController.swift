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
    
    @IBAction func refreshBtn(_ sender: Any) {
        self.apesterUnitView.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = UnitConfigurationsFactory.configurations(for: .production, hideApesterAds: false, gdprString: nil, baseUrl: "")[0]

        if let unit = unitParams {
            // preLoad implemntation
            apesterUnitView = APEViewService.shared.unitView(for: unit.id)
        }
        
        if apesterUnitView == nil {
            // not preload!
            apesterUnitView = APEUnitView(configuration: configuration)

        }

        apesterUnitView?.delegate = self

        apesterUnitView.display(in: unitContainerView, containerViewConroller: self)
        
        apesterUnitView.setGdprString(UnitConfigurationsFactory.gdprString)
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
