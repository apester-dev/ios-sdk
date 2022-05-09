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
        case pubMatic(param: PubMaticParams)
        case gad(params: GADParams)
        
        static func == (lhs: Monetization, rhs: Monetization) -> Bool {
            switch (lhs, rhs) {
            case (.pubMatic(let lhsParams), .pubMatic(let rhsParams)):
                return lhsParams.adType == rhsParams.adType
            case (.gad(let lhsParams), .gad(let rhsParams)):
                return lhsParams.adUnitId == rhsParams.adUnitId
            default: return false
            }
        }
    }
        
    struct GADParams: Hashable {
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
    
    struct PubMaticParams: Hashable {
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
