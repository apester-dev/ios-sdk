//
//  APEPubMaticAdParameters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/26/23.
//  Copyright © 2021 Apester. All rights reserved.
//
import Foundation
///
///
///
internal struct APEPubMaticAdParameters : Hashable , APEAdParameters
{
    internal let identifier     : String
    internal let isVariant      : Bool
    internal let type           : APEAdType
    
    internal let profileId      : Int
    internal let publisherId    : String
    internal let appStoreUrl    : String
    internal let appDomain      : String
    internal let testMode       : Bool
    internal let debugLogs      : Bool
    internal let bidSummaryLogs : Bool
    internal let timeInView     : Int?
     
    internal init?(_ dictionary: [String: Any])
    {
        self.init(from: dictionary)
    }
    
    internal init?(from dictionary: [String: Any])
    {
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
