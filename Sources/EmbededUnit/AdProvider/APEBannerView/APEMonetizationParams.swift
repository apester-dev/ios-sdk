    //
    //  APEMonetizationParams.swift
    //  ApesterKit
    //
    //  Created by Hasan Sawaed Tabash on 09/05/2022.
    //  Copyright © 2022 Apester. All rights reserved.
    //

import Foundation

extension APEUnitView {
    
    enum Monetization: Equatable {
        case pubMatic(params: PubMaticParams)
        case adMob(params: AdMobParams)
        
        static func == (lhs: Monetization, rhs: Monetization) -> Bool {
            switch (lhs, rhs) {
            case (.pubMatic (let lhsParams), .pubMatic  (let rhsParams)): return lhsParams.adType   == rhsParams.adType
            case (.adMob    (let lhsParams), .adMob     (let rhsParams)): return lhsParams.adUnitId == rhsParams.adUnitId
            default: return false
            }
        }
        
        var adType: AdType {
            switch self {
            case .pubMatic(let params): return params.adType
            case .adMob   (let params): return params.adType
            }
        }
        
        enum AdType: String {
            case bottom
            case inUnit
            case companion
            
            var size: CGSize {
                switch self {
                case .bottom: return .init(width: 320, height: 50)
                case .inUnit: return .init(width: 300, height: 250)
                case .companion: return .init(width: 300, height: 250)
                }
            }
        }
    }
        
    struct AdMobParams: Hashable {
        let adUnitId: String
        let isCompanionVariant: Bool
        let adType: Monetization.AdType
        
        init?(from dictionary: [String: Any]) {
            guard let provider = dictionary[Constants.Monetization.adProvider] as? String,
                  provider == Constants.Monetization.adMob,
                  let adUnitId = dictionary[Constants.Monetization.adUnitId] as? String,
                  let isCompanionVariant = dictionary[Constants.Monetization.isCompanionVariant] as? Bool,
                  let adTypeStr = dictionary[Constants.Monetization.adType] as? String,
                  let adType = Monetization.AdType(rawValue: adTypeStr) else {
                return nil
            }
            self.init(adUnitId: adUnitId, isCompanionVariant: isCompanionVariant, adType: adType)
        }
        
        init(adUnitId: String, isCompanionVariant: Bool, adType: Monetization.AdType) {
            self.adUnitId = adUnitId
            self.isCompanionVariant = isCompanionVariant
            self.adType = adType
        }
    }
    
    struct PubMaticParams: Hashable {
        let adUnitId: String
        let isCompanionVariant: Bool
        let adType: Monetization.AdType
        let profileId: Int
        let publisherId: String
        let appStoreUrl: String
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
                  let adUnitId = dictionary[Constants.Monetization.adUnitId] as? String,
                  let adTypeStr = dictionary[Constants.Monetization.adType] as? String,
                  let adType = Monetization.AdType(rawValue: adTypeStr) else {
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
