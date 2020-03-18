//
//  APEUnitConfiguration.swift
//  ApesterKit
//
//  Created by Almog Haimovitch on 10/03/2020.
//  Copyright © 2020 Apester. All rights reserved.
//

import UIKit

public enum APEUnitParams {
    case unit(mediaId: String)
    case playlist(tags: [String], channelToken: String, context: Bool, fallback: Bool)
    var id:String {
        switch self {
        case .unit(let mediaId):
            return mediaId
        case .playlist( _, let channelToken, _, _):
            return channelToken
        }
    }
}

@objcMembers public class APEUnitConfiguration: NSObject {
    
    private enum Keys: String {
        case mediaId = "mediaId"
        case channelToken = "channelToken"
        case tags = "tags"
        case context = "context"
        case fallback = "fallback"
        case noApesterAds = "noApesterAds"
    }
    
    public private(set) var unitParams: APEUnitParams
    private(set) var bundleInfo: [String : String]
    private(set) var environment: APEUnitEnvironment
    private(set) var id: String = ""
    private(set) var noApesterAds: Bool
    
    private var parameters: [String: String] {
        
        var value = self.bundleInfo.merging([], uniquingKeysWith: { $1 })
        switch self.unitParams {
        case .unit(let mediaId):
            value[Keys.mediaId.rawValue] = mediaId
            value[Keys.noApesterAds.rawValue] = String(self.noApesterAds)
        case .playlist(let tags, let channelToken, let context, let fallback):
            value[Keys.channelToken.rawValue] = channelToken
            value[Keys.context.rawValue] = String(context)
            value[Keys.fallback.rawValue] = String(fallback)
            value[Keys.tags.rawValue] = tags.joined(separator:",")
            value[Keys.noApesterAds.rawValue] = String(self.noApesterAds)
        }
        return value
    }
    
    var unitURL: URL? {
        return self.parameters.componentsURL(baseURL: (self.environment.baseUrl + Constants.Unit.unitPath))
    }
    
    public init(unitParams: APEUnitParams, bundle: Bundle, environment: APEUnitEnvironment, noApesterAds: Bool){
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
        self.environment = environment
        self.unitParams = unitParams
        self.noApesterAds = noApesterAds
    }
    
    public convenience init(unitParams: APEUnitParams, bundle: Bundle) {
        self.init(unitParams: unitParams, bundle: bundle, environment: .production, noApesterAds: false)
    }
    
    @objc public convenience init(mediaId: String, bundle: Bundle) {
        self.init(unitParams: .unit(mediaId: mediaId),
                  bundle: bundle)
    }
    @objc public convenience init(tags: [String], channelToken: String, context: Bool, fallback: Bool, bundle: Bundle) {
        self.init(unitParams: .playlist(tags: tags, channelToken: channelToken, context: context, fallback: fallback),
                  bundle: bundle)
    }
    
}
