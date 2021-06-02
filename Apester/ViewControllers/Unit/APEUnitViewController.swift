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
    
    var apesterUnitView: APEUnitView!

    private var unitParams: APEUnitParams? = UnitConfigurationsFactory.unitsParams.first
    
    @IBOutlet weak var unitContainerView: UIView!
    
    @IBAction func refreshBtn(_ sender: Any) {
        self.apesterUnitView.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = UnitConfigurationsFactory.configurations(for: .local, hideApesterAds: false, gdprString: nil, baseUrl: nil)[0]

        // For fullscreen mode set to true.
        let fullscreen = false;

        configuration.setFullscreen(fullscreen);
        
        if let unit = unitParams {
            // preLoad implemntation
            apesterUnitView = APEViewService.shared.unitView(for: unit.id)
        }
        
        if apesterUnitView == nil {
            // not preload!
            apesterUnitView = APEUnitView(configuration: configuration)

        }
//        apesterUnitView.setGdprString("new consent")
        apesterUnitView.subscribe(events: ["fullscreen_off"])
        apesterUnitView?.delegate = self

        apesterUnitView.display(in: unitContainerView, containerViewConroller: self)
        
        if fullscreen {
            
        // This to handle minmize app with full screen
            if #available(iOS 13.0, *) {
                NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(willBackActive), name: UIScene.willEnterForegroundNotification, object: nil)
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(willBackActive), name: UIApplication.willEnterForegroundNotification, object: nil)
            }
        }
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
