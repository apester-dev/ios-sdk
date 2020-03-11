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
    
    var apeUnitWebView: APEUnitWebViewV2!
    let configuration = try? APEUnitConfiguration(mediaId: "5e67832958c4d8457106a2ed",
                                                  bundle: Bundle.main, environment: .stage)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = setupContainerView()
        
        guard let unitConfig = configuration else { return }
        apeUnitWebView = APEUnitWebViewV2(unitConfig)
        
        let apesterUnit = apeUnitWebView.getWebView();
        containerView.addSubview(apesterUnit)
    }
    
    func setupContainerView() -> UIView {
        let myView = UIView(frame: .zero)
        myView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(myView)
        
        myView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        myView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        myView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        return myView
    }

}
