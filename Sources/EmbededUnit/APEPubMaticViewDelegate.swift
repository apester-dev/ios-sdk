//
//  PubMaticViewDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 03/10/2021.
//  Copyright © 2021 Apester. All rights reserved.
//

import Foundation
import WebKit

extension APEUnitView {
    
    struct PubMaticViewProvider {
        var view: POBBannerView?
        var delegate: PubMaticViewDelegate?
    }
    
    struct PubMaticProviderParams: Hashable {
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
    
    class PubMaticViewDelegate: NSObject, POBBannerViewDelegate {
        weak var containerViewController: UIViewController?
        private let receiveAdSuccessCompletion: ((PubMaticProviderParams.AdType) -> Void)
        private let receiveAdErrorCompletion: ((PubMaticProviderParams.AdType, Error?) -> Void)
        private let adType: PubMaticProviderParams.AdType
        
        init(adType: PubMaticProviderParams.AdType,
            containerViewController: UIViewController?,
            receiveAdSuccessCompletion: @escaping ((PubMaticProviderParams.AdType) -> Void),
            receiveAdErrorCompletion: @escaping ((PubMaticProviderParams.AdType, Error?) -> Void)
        ) {
            self.adType = adType
            self.containerViewController = containerViewController
            self.receiveAdSuccessCompletion = receiveAdSuccessCompletion
            self.receiveAdErrorCompletion = receiveAdErrorCompletion
        }
        
        func bannerViewPresentationController() -> UIViewController {
            self.containerViewController ?? UIApplication.shared.windows.first!.rootViewController!
        }

        func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
            receiveAdSuccessCompletion(adType)
        }
        
        func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error?) {
            receiveAdErrorCompletion(adType, error)
        }
        
        func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {}
        
        func bannerViewWillPresentModal(_ bannerView: POBBannerView) {}
        
        func bannerViewDidDismissModal(_ bannerView: POBBannerView) {}
    }
    
}
