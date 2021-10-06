//
//  APEGADViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation

extension APEUnitView {
    
    struct GADViewProvider {
        var view: GADBannerView?
        var delegate: GADViewDelegate?
    }
}
extension APEUnitView.GADViewProvider {
    
    struct Params: Hashable {
        let adUnitId: String
        let isCompanionVariant: Bool
        
        init?(from dictionary: [String: Any]) {
            guard let provider = dictionary[Constants.Monetization.adProvider] as? String,
                  provider == Constants.Monetization.adMob,
                  let adUnitId = dictionary[Constants.Monetization.adMobUnitId] as? String,
                  let isCompanionVariant = dictionary[Constants.Monetization.isCompanionVariant] as? Bool else {
                return nil
            }
            self.adUnitId = adUnitId
            self.isCompanionVariant = isCompanionVariant
        }
    }
}

// MARK:- Google ADs
extension APEUnitView {
    
    private func makeGADViewDelegate() -> GADViewDelegate {
        GADViewDelegate(containerViewController: containerViewController,
                        receiveAdSuccessCompletion: { [weak self] in
                           guard let self = self else { return }
                           self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                    Constants.Monetization.playerMonImpression)
                        },
                        receiveAdErrorCompletion: { [weak self] error in
                           guard let self = self else { return }
                           self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                    Constants.Monetization.playerMonLoadingImpressionFailed)
                           print(error?.localizedDescription ?? "")
                        })
    }
    
    func setupGADView(params: GADViewProvider.Params) {
        var gADView = gADViewProviders[params]?.view
        if gADView == nil {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
            gADView = GADBannerView(adSize: kGADAdSizeBanner)
            gADView?.translatesAutoresizingMaskIntoConstraints = false
            let delegate = gADViewProviders[params]?.delegate ?? self.makeGADViewDelegate()
            gADView?.delegate = delegate
            self.gADViewProviders[params] = .init(view: gADView, delegate: delegate)
        }
        gADView?.adUnitID = params.adUnitId
        gADView?.load(GADRequest())
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonImpressionPending)
        showGADView()
    }
    
    func showGADView() {
        guard let containerView = unitWebView, let containerViewController = self.containerViewController else { return }
        gADViewProviders.forEach { params, provider in
            guard let gADView = provider.view else { return }
            containerView.addSubview(gADView)
            gADView.rootViewController = containerViewController
            gADView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(gADViewLayoutConstraints(gADView, containerView: containerView, isCompanionVariant: params.isCompanionVariant))
        }
    }
    
    private func gADViewLayoutConstraints(_ gADView: GADBannerView, containerView: UIView, isCompanionVariant: Bool) -> [NSLayoutConstraint] {
        var constraints = [
            gADView.leadingAnchor.constraint(equalTo: unitWebView.leadingAnchor),
            gADView.trailingAnchor.constraint(equalTo: unitWebView.trailingAnchor)
        ]
        if isCompanionVariant {
            constraints.append(gADView.topAnchor.constraint(equalTo: unitWebView.bottomAnchor, constant: 0))
        } else {
            constraints.append(gADView.bottomAnchor.constraint(equalTo: unitWebView.bottomAnchor, constant: 0))
        }
        return constraints
    }
}
