//
//  APEAmazonAdParameters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/26/23.
//  Copyright © 2021 Apester. All rights reserved.
//
import Foundation
///
///
///
internal struct APEAmazonAdParameters : Hashable , APEAdParameters
{
    enum CodingKeys : String , CustomStringConvertible
    {
        case amazon_key
        case amazon_slotID
        case amazon_dfp_au
        var description : String { return rawValue }
    }
    
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
    
    internal let amazon_key     : String
    internal let amazon_slotID  : String
    internal let dfp_au_banner  : String
    
    internal init?(_ dictionary: [String: Any])
    {
        self.init(from: dictionary)
    }
    
    internal init?(from dictionary1: [String: Any])
    {
        var dictionary = dictionary1
        typealias Keys = Constants.Monetization
        
        guard let provider  = dictionary[Keys.adProvider] as? String , provider == Keys.amazon else { return nil }
        guard let adUnitId  = dictionary[Keys.adUnitId  ] as? String else { return nil }
        guard let typeStr   = dictionary[Keys.adType    ] as? String else { return nil }
        guard let isVariant = dictionary[Keys.isVariant ] as? Bool   else { return nil }
        
        guard let adType    = APEAdType(rawValue: typeStr) else { return nil }
        
        guard let profileIdStr = dictionary[Keys.profileId  ] as? String , let profileId = Int(profileIdStr) else {
            return nil
        }
        guard let appStoreUrl  = dictionary[Keys.appStoreUrl] as? String else { return nil }
        guard let publisherId  = dictionary[Keys.publisherId] as? String else { return nil }
        
        dictionary[CodingKeys.amazon_key   .description] = "a9_onboarding_app_id"
        dictionary[CodingKeys.amazon_slotID.description] = "5ab6a4ae-4aa5-43f4-9da4-e30755f2b295"
        dictionary[CodingKeys.amazon_dfp_au.description] = "/15671365/pm_sdk/A9_Demo"
        
        guard var a_key    = dictionary[CodingKeys.amazon_key   .description] as? String else { return nil }
        guard var a_slotID = dictionary[CodingKeys.amazon_slotID.description] as? String else { return nil }
        guard var a_dfp_au = dictionary[CodingKeys.amazon_dfp_au.description] as? String else { return nil }
        
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
        
        self.amazon_key     = a_key
        self.amazon_slotID  = a_slotID
        self.dfp_au_banner  = a_dfp_au
    }
}
