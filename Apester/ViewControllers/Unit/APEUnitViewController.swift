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
    
    @IBAction func refreshButton(_ sender: Any) {
        apesterUnitView.reload()
    }
    
    private var apesterUnitView: APEUnitView!

    private var unitParams: APEUnitParams? = UnitConfigurationsFactory.unitsParams.first
    
    @IBOutlet weak var unitContainerView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let configuration = UnitConfigurationsFactory.configurations(
            hideApesterAds: false,
            gdprString: nil,
            baseUrl: nil
        ).first else { return }

        // For fullscreen mode set to be true.
        let fullscreen = false;

        configuration.setFullscreen(fullscreen);
        
        if let unit = unitParams {
            // preLoad implementation
            apesterUnitView = APEViewService.shared.unitView(for: unit.id)
        }
        
        if apesterUnitView == nil {
            // not preload!
            apesterUnitView = APEUnitView(configuration: configuration)

        }
//        apesterUnitView.setGdprString("new consent")
        apesterUnitView.subscribe(events: ["fullscreen_off"])
        apesterUnitView?.delegate = self

        apesterUnitView.display(in: unitContainerView, containerViewController: self)
        
        // This to handle minimize app with full screen
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willBackActive),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        apesterUnitView.stop()
    }
    
    @objc func willBackActive(_ notification: Notification) {
        apesterUnitView.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        apesterUnitView.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        apesterUnitView.resume()
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
    
    func unitView(_ unitView: APEUnitView, didReciveEvent name: String, message: String) {
        if name == "fullscreen_off" {
            print("almog fullscreen_off")
        }
    }

}
