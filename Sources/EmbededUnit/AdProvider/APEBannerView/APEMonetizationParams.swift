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
            case (.pubMatic(let l), .pubMatic(let r)): return l.adUnitId == r.adUnitId && l.adType   == r.adType
            case (.adMob   (let l), .adMob   (let r)): return l.adUnitId == r.adUnitId && l.adType   == r.adType
            default: return false
            }
        }
        
        enum AdType: String , CustomStringConvertible {
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
            var height : CGFloat { return size.height }
            var width  : CGFloat { return size.width  }
            
            var description : String { return rawValue }
        }
        
        var adUnitId: String {
            switch self {
            case .pubMatic(let params): return params.adUnitId
            case .adMob   (let params): return params.adUnitId
            }
        }
        var isCompanionVariant: Bool {
            switch self {
            case .pubMatic(let params): return params.isCompanionVariant
            case .adMob   (let params): return params.isCompanionVariant
            }
        }
        var adType: AdType {
            switch self {
            case .pubMatic(let params): return params.adType
            case .adMob   (let params): return params.adType
            }
        }
    }
    
    struct AdMobParams: Hashable {
        let adUnitId: String
        let isCompanionVariant: Bool
        let adType: Monetization.AdType
        
        init?(from dictionary: [String: Any]) {
            
            typealias Keys = Constants.Monetization
            
            guard let provider = dictionary[Keys.adProvider] as? String , provider == Keys.adMob else { return nil }
            guard let adUnitId = dictionary[Keys.adUnitId] as? String else { return nil }
            guard let typeStr  = dictionary[Keys.adType  ] as? String else { return nil }
            guard let adType = Monetization.AdType(rawValue: typeStr) else { return nil }
            guard let isVariant = dictionary[Keys.isCompanionVariant] as? Bool else { return nil }
            
            self.init(adUnitId: adUnitId, isCompanionVariant: isVariant, adType: adType)
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
            
            typealias Keys = Constants.Monetization
            
            guard let provider = dictionary[Keys.adProvider] as? String , provider == Keys.pubMatic else { return nil }
            guard let adUnitId = dictionary[Keys.adUnitId] as? String else { return nil }
            guard let typeStr  = dictionary[Keys.adType  ] as? String else { return nil }
            guard let adType = Monetization.AdType(rawValue: typeStr) else { return nil }
            guard let isVariant = dictionary[Keys.isCompanionVariant] as? Bool else { return nil }
            
            guard let profileIdStr = dictionary[Keys.profileId  ] as? String , let profileId = Int(profileIdStr) else {
                return nil
            }
            guard let appStoreUrl  = dictionary[Keys.appStoreUrl] as? String else { return nil }
            guard let publisherId  = dictionary[Keys.publisherId] as? String else { return nil }
            
            self.adUnitId           = adUnitId
            self.adType             = adType
            self.isCompanionVariant = isVariant
            self.profileId          = profileId
            self.appStoreUrl        = appStoreUrl
            self.publisherId        = publisherId
            self.appDomain          = dictionary[Keys.appDomain     ] as? String ?? ""
            self.testMode           = dictionary[Keys.testMode      ] as? Bool ?? false
            self.debugLogs          = dictionary[Keys.debugLogs     ] as? Bool ?? false
            self.bidSummaryLogs     = dictionary[Keys.bidSummaryLogs] as? Bool ?? false
            self.timeInView         = dictionary[Keys.timeInView    ] as? Int
        }
    }
}
