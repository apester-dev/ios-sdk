//
//  APEAniViewParameters.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 4/16/24.
//  Copyright © 2021 Apester. All rights reserved.
//
import Foundation
///
///
///
internal struct APEAniViewParameters : Hashable , APEAdParameters
{
    fileprivate enum CodingKeys : String , CustomStringConvertible
    {
        case appStoreUrl    = "appStoreUrl"
        case adProvider     = "provider"
        case channel        = "channelId"
        case playerId       = "playerId"
        case adType         = "adType"
        case isVariant      = "isCompanionVariant"
        
        fileprivate var description : String { return rawValue }
    }
    
    internal let identifier     : String
    internal let isVariant      : Bool
    internal let type           : APEAdType
    
    internal let channelId      : String
    internal let appStoreUrl    : String
    
    internal init?(from dictionary: [String: Any])
    {
        typealias Keys = CodingKeys
        
         let appstoreUrl   = "https://apps.apple.com/us/app/apester-app/id6478967119"
//        dictionary[Keys.appStoreUrl   .description] as? String else { return nil }
        guard let channelId     = dictionary[Keys.channel       .description] as? String else { return nil }
        guard let provider      = dictionary[Keys.adProvider    .description] as? String else { return nil }
        guard let playerId      = dictionary[Keys.playerId      .description] as? String else { return nil }
        guard let typeStr       = dictionary[Keys.adType        .description] as? String else { return nil }
        guard let isVariant     = dictionary[Keys.isVariant     .description] as? Bool   else { return nil }
        
        guard provider == Constants.Monetization.aniview  else { return nil }
        guard let adType = APEAdType(rawValue: typeStr) else { return nil }
        
        self.identifier     = playerId
        self.isVariant      = isVariant
        self.type           = adType
        self.appStoreUrl    = appstoreUrl
        self.channelId      = channelId
    }
}
