//
//  UnitConfigurationFactory.swift
//  Apester
//
//  Created by Almog Haimovitch on 11/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit
import ApesterKit

@objcMembers class UnitConfigurationsFactory: NSObject {
    
    static var environment: APEEnvironment = .production
    
    static private(set) var unitsParams: [APEUnitParams] = []
    
    static func unitsIds() -> [String] { unitsParams.map(\.id) }
    
    static var gdprString = "CPlrcMAPlrcMACnABIDECzCkAP_AAAAAAAYgI8pd9D7dbXFDefx_SPt0OYwW0NBTKuQCChSAA2AFVAOQcLQA02EaMATAhiACEQIAolIBAAEEHAFUAECQQIAEAAHsIgSEhAAKIABEEBEQAAIQAAoKAAAAEAAIgAABIgSAmBiQS5LmRUCAGIAQBgBYgogBCIABAgMBBEAIABgIAIIIwygAAQAAAIIAAAAAARAAAgAAAJCQAYAAgjyGgAwABBHkRABgACCPIqADAAEEeRkAGAAII8joAMAAQR5IQAYAAgjySgAwABBHkpABgACCPIAA.f_gAAAAABcgAAAAA"
    // static var gdprString : String? = nil
    static var baseUrl: String = "https://www.kicker.de/apester-in-app-unit-detached?__APESTER_DEBUG__=true"
    static func configurations(hideApesterAds: Bool, gdprString: String? = nil, baseUrl: String? = nil) -> [APEUnitConfiguration]  {
        
        var unitsParams: [APEUnitParams]!
        
        switch environment {
        case .production:
            unitsParams = [
              .unit(mediaId: "65941b08a7dea3751aad1574"), // ADMob Test
//               .unit(mediaId: "65732bc74862859b7c33cfdf"),
//                .unit(mediaId: "6567528b0833500f6a825511"),
//               .unit(mediaId: "65673b98b5c744a440d4a8df"),
//                 ADMob Test
               // .unit(mediaId: "61ee7ff6a5e14a002b6c044a"), //.unit(mediaId: "60eeda29b54b6f002448ba79"),
               //sport1
                .playlist(tags: [], channelToken: "61ee7fd7a33874001368f396", context: false, fallback: false),
               // kicker
//                .playlist(tags: [], channelToken: "61ee7fd7a33874001368f396", context: false, fallback: false)
//                .playlist(tags: [], channelToken: "61ee7fd7a33874001368f396", context: false, fallback: false)
           ]
        case .stage:
            unitsParams = [
                .playlist(tags: [], channelToken: "64d0ae93dc9c1f0012f5cf23", context: false, fallback: false),
//                .unit(mediaId: "613d0754e9d41e0024816a38"),
//                .unit(mediaId: "5e6fa2351d18fd8580776612"),
//                .playlist(tags: ["news", "sport", "yoga"],
//                          channelToken: "5dcbc10016698427404a0f57",
//                          context: false,
//                          fallback: false),
//                .playlist(tags: ["yo", "bo", "ho"],
//                          channelToken: "5dde8f05694a5dc20a16f3c8",
//                          context: false,
//                          fallback: false),
            ]
        case .dev:
            unitsParams = [
                // .unit(mediaId: "62a5c51e7c1ce9002a94941f"),
                .playlist(tags: [], channelToken: "610a3f7dabe1d5003c662f3b", context: false, fallback: false)
            ]
        }
        self.unitsParams = unitsParams
        return makeUnitConfigurations(with: unitsParams, environment: environment, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: baseUrl)
    }
    
    static private func getUnitParam(isPlaylist: Bool, mediaId: String?, channelToken: String?, tags: [String]?, context: Bool?, fallback: Bool?, noApesterAds: Bool) -> [APEUnitParams] {
        return isPlaylist ? [.playlist(tags: tags!, channelToken: channelToken ?? "", context: context ?? false, fallback: fallback ?? false)] : [.unit(mediaId: mediaId!)]
    }
    
    /// transform given media id to APEStripConfiguration
    /// - Parameter unitIds: the unitParams to transform
    static func makeUnitConfigurations(with unitParams: [APEUnitParams], environment: APEEnvironment, hideApesterAds: Bool, gdprString: String?, baseUrl: String?) -> [APEUnitConfiguration] {
        
        unitParams.compactMap {
            APEUnitConfiguration(unitParams: $0, bundle: Bundle.main, hideApesterAds: hideApesterAds, gdprString: gdprString, baseUrl: baseUrl, environment: environment)
        }
        
    }
}
