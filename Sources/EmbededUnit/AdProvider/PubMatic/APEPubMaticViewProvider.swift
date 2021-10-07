
//
//  APEPubMaticViewProvider.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 06/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation


extension APEUnitView {
    
    struct PubMaticViewProvider {
        var view: POBBannerView?
        var delegate: PubMaticViewDelegate?
    }
}

extension APEUnitView.PubMaticViewProvider {
    
    struct Params: Hashable {
        enum AdType: String {
            case bottom
            case inUnit
            
            var size: CGSize {
                switch self {
                case .bottom: return .init(width: 320, height: 50)
                case .inUnit: return .init(width: 300, height: 250)
                }
            }
        }
        let adUnitId: String
        let profileId: Int
        let publisherId: String
        let appStoreUrl: String
        let isCompanionVariant: Bool
        let adType: AdType
        let appDomain: String
        let testMode: Bool
        let debugLogs: Bool
        let bidSummaryLogs: Bool
        let timeInView: Int?
        
        init?(from dictionary: [String: Any]) {
            guard let provider = dictionary[Constants.Monetization.adProvider] as? String,
                  provider == Constants.Monetization.pubMatic,
                  let appStoreUrl = dictionary[Constants.Monetization.appStoreUrl] as? String,
                  let profileIdStr = dictionary[Constants.Monetization.profileId] as? String,
                  let profileId = Int(profileIdStr),
                  let isCompanionVariant = dictionary[Constants.Monetization.isCompanionVariant] as? Bool,
                  let publisherId = dictionary[Constants.Monetization.publisherId] as? String,
                  let adUnitId = dictionary[Constants.Monetization.pubMaticUnitId] as? String,
                  let adTypeStr = dictionary[Constants.Monetization.adType] as? String,
                  let adType = AdType(rawValue: adTypeStr) else {
                return nil
            }
            self.adUnitId           = adUnitId
            self.profileId          = profileId
            self.publisherId        = publisherId
            self.appStoreUrl        = appStoreUrl
            self.isCompanionVariant = isCompanionVariant
            self.adType             = adType
            self.appDomain          = dictionary[Constants.Monetization.appDomain] as? String ?? ""
            self.testMode           = dictionary[Constants.Monetization.testMode] as? Bool ?? false
            self.debugLogs          = dictionary[Constants.Monetization.debugLogs] as? Bool ?? false
            self.bidSummaryLogs     = dictionary[Constants.Monetization.bidSummaryLogs] as? Bool ?? false
            self.timeInView         = dictionary[Constants.Monetization.timeInView] as? Int
        }
    }
}

// MARK:- PubMatic ADs
extension APEUnitView {
    
    private func makePubMaticViewDelegate(adType: PubMaticViewProvider.Params.AdType) -> PubMaticViewDelegate {
        PubMaticViewDelegate(adType: adType,
                             containerViewController: containerViewController,
                             receiveAdSuccessCompletion: { [weak self] adType in
                                guard let self = self else { return }
                                if case .inUnit = adType {
                                    self.pubMaticViewCloseButton.isHidden = false
                                }
                                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                         Constants.Monetization.playerMonImpression)
                             },
                             receiveAdErrorCompletion: { [weak self] adType, error in
                                guard let self = self else { return }
                                self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView,
                                                                         Constants.Monetization.playerMonLoadingImpressionFailed)
                                print(error?.localizedDescription ?? "")
                                if case .inUnit = adType {
                                    self.pubMaticViewCloseButton.isHidden = false
                                }
                                self.hidePubMaticView()
                             })
    }
    
    func setupPubMaticView(params: PubMaticViewProvider.Params) {
        defer {
            showPubMaticViews()
        }
        var pubMaticView = self.pubMaticViewProviders[params.adType]?.view
        guard pubMaticView == nil else {
            pubMaticView?.forceRefresh()
            return
        }
        let appInfo = POBApplicationInfo()
        appInfo.domain = params.appDomain
        appInfo.storeURL = URL(string: params.appStoreUrl)!
        OpenWrapSDK.setApplicationInfo(appInfo)
        
        self.messageDispatcher.sendNativeAdEvent(to: self.unitWebView, Constants.Monetization.playerMonLoadingPass)
        let adSizes = [POBAdSizeMake(params.adType.size.width, params.adType.size.height)].compactMap({ $0 })
        
        pubMaticView = POBBannerView(publisherId: params.publisherId,
                                     profileId: .init(value: params.profileId),
                                     adUnitId: params.adUnitId,
                                     adSizes: adSizes)
        
        pubMaticView?.request.testModeEnabled = params.testMode
        pubMaticView?.request.debug = params.debugLogs
        pubMaticView?.request.bidSummaryEnabled = params.bidSummaryLogs
        
        let delegate = pubMaticViewProviders[params.adType]?.delegate ?? makePubMaticViewDelegate(adType: params.adType)
        pubMaticView?.delegate = delegate
        pubMaticView?.loadAd()
        
        self.pubMaticViewProviders[params.adType] = PubMaticViewProvider(view: pubMaticView, delegate: delegate)
        
        guard  let timeInView = params.timeInView, pubMaticViewTimer == nil else { return }
        pubMaticViewTimer = Timer.scheduledTimer(withTimeInterval: Double(timeInView), repeats: false) { _ in
            self.hidePubMaticView()
        }
    }
    
    func removePubMaticView(of adType: PubMaticViewProvider.Params.AdType) {
        pubMaticViewProviders[adType]?.view?.removeFromSuperview()
        pubMaticViewProviders[adType] = nil
        guard pubMaticViewTimer != nil else { return }
        pubMaticViewCloseButton.removeFromSuperview()
        pubMaticViewTimer?.invalidate()
        pubMaticViewTimer = nil
    }
    
    @objc func hidePubMaticView() {
        removePubMaticView(of: .inUnit)
    }
    
    func showPubMaticViews() {
        self.pubMaticViewProviders
            .forEach({ type, provider in
                guard let containerView = unitWebView, let pubMaticView = provider.view else { return }
                containerView.addSubview(pubMaticView)
                containerView.bringSubviewToFront(pubMaticView)
                
                if case .inUnit = type {
                    if let bottomView = self.pubMaticViewProviders[.bottom]?.view {
                        containerView.bringSubviewToFront(bottomView)
                    }
                    self.pubMaticViewCloseButton.isHidden = true
                    containerView.addSubview(self.pubMaticViewCloseButton)
                    containerView.bringSubviewToFront(self.pubMaticViewCloseButton)
                }
                pubMaticView.translatesAutoresizingMaskIntoConstraints = false
                pubMaticView.removeConstraints(pubMaticView.constraints)
                NSLayoutConstraint.activate(pubMaticViewLayoutConstraints(pubMaticView, containerView: containerView, type: type))
            })
    }
    
    private func pubMaticViewLayoutConstraints(_ pubMaticView: POBBannerView, containerView: UIView, type: PubMaticViewProvider.Params.AdType) -> [NSLayoutConstraint] {
        var constraints = [pubMaticView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0),
                           pubMaticView.widthAnchor.constraint(equalToConstant: type.size.width),
                           pubMaticView.heightAnchor.constraint(equalToConstant: type.size.height)]
        switch type {
        case .bottom:
            constraints += [pubMaticView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)]
        case .inUnit:
            constraints += [pubMaticView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
                            pubMaticViewCloseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor,
                                                                             constant: type.size.width/2 + 7),
                            pubMaticViewCloseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor,
                                                                             constant: -type.size.height/2 - 7)
            ]
        }
        return constraints
    }
}
