//
//  APEAdMobAdParameters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/26/23.
//  Copyright © 2021 Apester. All rights reserved.
//
import Foundation
///
///
///
internal struct APEAdMobAdParameters : Hashable , APEAdParameters
{
    fileprivate enum CodingKeys : String , CustomStringConvertible
    {
        case adProvider     = "provider"
        case adUnitId       = "iosAdUnitId"
        case adType         = "adType"
        case isVariant      = "isCompanionVariant"
        
        fileprivate var description : String { return rawValue }
    }
    
    internal let identifier     : String
    internal let isVariant      : Bool
    internal let type           : APEAdType
    
    internal init?(from dictionary: [String: Any])
    {
        typealias Keys = CodingKeys
        
        guard let provider  = dictionary[Keys.adProvider.description] as? String else { return nil }
        guard let adUnitId  = dictionary[Keys.adUnitId  .description] as? String else { return nil }
        guard let typeStr   = dictionary[Keys.adType    .description] as? String else { return nil }
        guard let isVariant = dictionary[Keys.isVariant .description] as? Bool   else { return nil }
        
        guard provider == Constants.Monetization.adMob  else { return nil }
        guard let adType = APEAdType(rawValue: typeStr) else { return nil }
        
        self.identifier = adUnitId
        self.isVariant  = isVariant
        self.type       = adType
    }
}
