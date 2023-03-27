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
    internal let identifier     : String
    internal let isVariant      : Bool
    internal let type           : APEAdType
    
    internal init?(_ dictionary: [String: Any])
    {
        self.init(from: dictionary)
    }
    
    internal init?(from dictionary: [String: Any])
    {
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
