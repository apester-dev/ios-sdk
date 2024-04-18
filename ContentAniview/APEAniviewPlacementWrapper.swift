//
//  APEAniviewPlacementWrapper.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 4/17/24.
//
import UIKit
import AdPlayerSDK

class AdPlayerPlacementViewWrapper: UIView, APENativeLibraryAdView {
    
    func forceRefreshAd()  { /* NO OPERATION HERE */ }
    func proceedToTriggerLoadAd() { /* NO OPERATION HERE */ }
    
    var nativeSize: CGSize {
        // Implement according to APENativeLibraryAdView requirements
        return CGSize(width: 320, height: 50) // Example size
    }

    init(viewController: AdPlayerPlacementViewController) {
        super.init(frame: .zero)
        // Assuming AdPlayerPlacementViewController has a view property
        self.addSubview(viewController.view)
        viewController.view.frame = self.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

