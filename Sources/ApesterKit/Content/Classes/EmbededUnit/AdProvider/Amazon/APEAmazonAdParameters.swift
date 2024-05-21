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
    fileprivate enum CodingKeys : String , CustomStringConvertible
    {
        case adProvider 	= "provider"
        case adUnitId   	= "iosAdUnitId"
        case adType         = "adType"
        case isVariant      = "isCompanionVariant"
        case profileId      = "iosProfileId"
        case publisherId    = "publisherId"
        case appStoreUrl    = "iosAppStoreUrl"
        case appDomain      = "appDomain"
        case testMode       = "testMode"
        case debugLogs      = "debugLogs"
        case bidSummaryLogs = "bidSummaryLogs"
        case timeInView     = "timeInView"
        
        case amazon_app_key = "iosAmazonAppId"
        case amazon_slotID  = "iosAmazonUuid"
        case amazon_dfp_au  = "iosGamAdUnit"
        
        fileprivate var description : String { return rawValue }
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
    
    internal init?(from dictionary: [String: Any])
    {
        typealias Keys = CodingKeys
        
        guard let provider      = dictionary[Keys.adProvider    .description] as? String else { return nil }
        guard let adUnitId      = dictionary[Keys.adUnitId      .description] as? String else { return nil }
//        guard
        let typeStr       = APEAdType.interstitial.description
//                dictionary[Keys.adType        .description] as? String else { return nil }
        guard let isVariant     = dictionary[Keys.isVariant     .description] as? Bool   else { return nil }
        guard let profileIdStr  = dictionary[Keys.profileId     .description] as? String else { return nil }
        guard let appStoreUrl   = dictionary[Keys.appStoreUrl   .description] as? String else { return nil }
        guard let publisherId   = dictionary[Keys.publisherId   .description] as? String else { return nil }
        guard let amazon_key    = dictionary[Keys.amazon_app_key.description] as? String else { return nil }
        guard let amazon_slotID = dictionary[Keys.amazon_slotID .description] as? String else { return nil }
        guard let amazon_dfp_au = dictionary[Keys.amazon_dfp_au .description] as? String else { return nil }
        
        guard provider == Constants.Monetization.pubMatic  else { return nil }
        guard let adType    = APEAdType(rawValue: typeStr) else { return nil }
        guard let profileId = Int(profileIdStr)            else { return nil }
        guard !amazon_key.isEmpty && !amazon_slotID.isEmpty && !amazon_dfp_au.isEmpty else { return nil }
        
        self.identifier     = adUnitId
        self.isVariant      = isVariant
        self.type           = adType
        self.profileId      = profileId
        self.appStoreUrl    = appStoreUrl
        self.publisherId    = publisherId
        self.appDomain      = dictionary[Keys.appDomain     .description] as? String ?? ""
        self.testMode       = true
//        dictionary[Keys.testMode      .description] as? Bool ?? false
        self.debugLogs      = dictionary[Keys.debugLogs     .description] as? Bool ?? false
        self.bidSummaryLogs = dictionary[Keys.bidSummaryLogs.description] as? Bool ?? false
        self.timeInView     = dictionary[Keys.timeInView    .description] as? Int
        self.amazon_key     = amazon_key
        self.amazon_slotID  = amazon_slotID
        self.dfp_au_banner  = amazon_dfp_au
    }
}
