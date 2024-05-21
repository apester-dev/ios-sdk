//
//  APEIntertitialWrapper.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 5/19/24.
//

import UIKit
import OpenWrapSDK

class APEInterstitialAdWrapper: UIView, APENativeLibraryAdView {
     var interstitial: POBInterstitial

    // Initialize with a POBInterstitial instance
    init(interstitial: POBInterstitial) {
        self.interstitial = interstitial
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        // Setup the view hierarchy or layout if needed
        self.interstitial.delegate = self
        self.backgroundColor = .clear
        
    }

    var nativeSize: CGSize {
        // You may want to set a default size or update it based on the content size of ads
        return CGSize(width: 320, height: 480) // Example size, adjust as necessary
    }

    func forceRefreshAd() {
        interstitial.loadAd()
    }

    func proceedToTriggerLoadAd() {
        // Ensure that you have a view controller to present the ad
        if let topController = UIApplication.shared.topMostViewController() {
            interstitial.show(from: topController)
        }
    }

    // Optionally, add a method to handle the setup of the interstitial
    func setupInterstitialDelegate() {
    }
}

// Extend UIApplication to find the top most view controller
extension UIApplication {
    func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow?.rootViewController else {
            return nil
        }
        var topController: UIViewController = rootController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}

// Conform to the delegate to handle events
extension APEInterstitialAdWrapper: POBInterstitialDelegate {
    func interstitialDidReceiveAd(_ interstitial: POBInterstitial) {
        print("Ad received")
    }

    func interstitial(_ interstitial: POBInterstitial, didFailToReceiveAdWithError error: NSError) {
        print("Failed to receive ad: \(error.localizedDescription)")
    }

    func interstitialDidDismissAd(_ interstitial: POBInterstitial) {
        print("Ad dismissed")
    }
}
