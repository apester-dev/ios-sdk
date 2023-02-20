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
    
    static func configurations(hideApesterAds: Bool, gdprString: String? = nil, baseUrl: String? = nil) -> [APEUnitConfiguration]  {
        
        var unitsParams: [APEUnitParams]!
        
        switch environment {
        case .production:
            unitsParams = [
                // // .unit(mediaId: "6231aab6b6a111002a435a45"), // ADMob Test
                // .unit(mediaId: "61ee7ff6a5e14a002b6c044a"), //.unit(mediaId: "60eeda29b54b6f002448ba79"),
                // .playlist(tags: [], channelToken: "5f85919d44959d32decd9d31", context: false, fallback: false),
                .playlist(tags: [], channelToken: "61ee7fd7a33874001368f396", context: false, fallback: false)
            ]
        case .stage:
            unitsParams = [
                .unit(mediaId: "613d0754e9d41e0024816a38"),
                .unit(mediaId: "5e6fa2351d18fd8580776612"),
                .playlist(tags: ["news", "sport", "yoga"],
                          channelToken: "5dcbc10016698427404a0f57",
                          context: false,
                          fallback: false),
                .playlist(tags: ["yo", "bo", "ho"],
                          channelToken: "5dde8f05694a5dc20a16f3c8",
                          context: false,
                          fallback: false),
            ]
        case .local:
            unitsParams = [
                .unit(mediaId: "5e67bd1c6abc6400725787ab"),
                .playlist(tags: ["news", "sport", "yoga"],
                          channelToken: "5d6fc15d07d512002b67ecc6",
                          context: false,
                          fallback: false),
            ]
        case .dev:
            unitsParams = [
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
