//
//  APEMonetizationParams.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 09/05/2022.
//  Copyright © 2022 Apester. All rights reserved.
//

import Foundation

enum APEAdSize {
    
    case adSize320x50
    case adSize300x250
    
    var size : CGSize {
        switch self {
        case .adSize320x50 : return .init(width: 320, height: 50)
        case .adSize300x250: return .init(width: 300, height: 250)
        }
    }
}

enum APEAdType : String , CustomStringConvertible {
    
    case bottom    = "bottom"
    case inUnit    = "inUnit"
    case companion = "companion"
    
    var supportedSizes: [APEAdSize] {
        switch self {
        case .bottom: return [.adSize320x50]
        case .inUnit: return [.adSize300x250]
        case .companion: return [.adSize300x250, .adSize320x50]
        }
    }
    var description : String { return rawValue }
}

protocol AdParameters {
    var identifier : String    { get }
    var isVariant  : Bool      { get }
    var type       : APEAdType { get }
}

extension APEUnitView {
    
    enum Monetization: Equatable {
        
        case adMob   (params: AdMobParams   )
        case pubMatic(params: PubMaticParams)
        
        static func == (lhs: Monetization, rhs: Monetization) -> Bool {
            switch (lhs, rhs) {
            case (.adMob   (let l), .adMob   (let r)): return l.identifier == r.identifier && l.type == r.type
            case (.pubMatic(let l), .pubMatic(let r)): return l.identifier == r.identifier && l.type == r.type
            default: return false
            }
        }
        var adUnitId : String {
            switch self {
            case .adMob   (let p): return p.identifier
            case .pubMatic(let p): return p.identifier
            }
        }
        var isCompanionVariant: Bool {
            switch self {
            case .adMob   (let p): return p.isVariant
            case .pubMatic(let p): return p.isVariant
            }
        }
        var adType: APEAdType {
            switch self {
            case .adMob   (let p): return p.type
            case .pubMatic(let p): return p.type
            }
        }
    }
    
    struct AdMobParams: Hashable , AdParameters {
        
        let identifier: String
        let isVariant : Bool
        let type: APEAdType
        
        init?(from dictionary: [String: Any]) {
            
            typealias Keys = Constants.Monetization
            
            guard let provider  = dictionary[Keys.adProvider] as? String , provider == Keys.adMob else { return nil }
            guard let adUnitId  = dictionary[Keys.adUnitId  ] as? String else { return nil }
            guard let typeStr   = dictionary[Keys.adType    ] as? String else { return nil }
            guard let isVariant = dictionary[Keys.isVariant ] as? Bool   else { return nil }
            
            guard let adType    = APEAdType(rawValue: typeStr) else { return nil }
            
            self.identifier = adUnitId
            self.isVariant = isVariant
            self.type = adType
        }
    }
    
    struct PubMaticParams: Hashable , AdParameters {
        
        let identifier: String
        let isVariant : Bool
        let type: APEAdType
        
        let profileId       : Int
        let publisherId     : String
        let appStoreUrl     : String
        let appDomain       : String
        let testMode        : Bool
        let debugLogs       : Bool
        let bidSummaryLogs  : Bool
        let timeInView      : Int?
        
        init?(from dictionary: [String: Any]) {
            
            typealias Keys = Constants.Monetization
            
            guard let provider  = dictionary[Keys.adProvider] as? String , provider == Keys.pubMatic else { return nil }
            guard let adUnitId  = dictionary[Keys.adUnitId  ] as? String else { return nil }
            guard let typeStr   = dictionary[Keys.adType    ] as? String else { return nil }
            guard let isVariant = dictionary[Keys.isVariant ] as? Bool   else { return nil }
            
            guard let adType    = APEAdType(rawValue: typeStr) else { return nil }
            
            guard let profileIdStr = dictionary[Keys.profileId  ] as? String , let profileId = Int(profileIdStr) else {
                return nil
            }
            guard let appStoreUrl  = dictionary[Keys.appStoreUrl] as? String else { return nil }
            guard let publisherId  = dictionary[Keys.publisherId] as? String else { return nil }
            
            self.identifier     = adUnitId
            self.isVariant      = isVariant
            self.type           = adType
            self.profileId      = profileId
            self.appStoreUrl    = appStoreUrl
            self.publisherId    = publisherId
            self.appDomain      = dictionary[Keys.appDomain     ] as? String ?? ""
            self.testMode       = dictionary[Keys.testMode      ] as? Bool ?? false
            self.debugLogs      = dictionary[Keys.debugLogs     ] as? Bool ?? false
            self.bidSummaryLogs = dictionary[Keys.bidSummaryLogs] as? Bool ?? false
            self.timeInView     = dictionary[Keys.timeInView    ] as? Int
        }
    }
}

