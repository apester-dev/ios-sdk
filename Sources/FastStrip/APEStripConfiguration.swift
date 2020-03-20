//
//  APEStripConfiguration.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit

public enum APEStripConfigurationError: Error {
    case invalidChannelToken
}

@objcMembers public class APEStripConfiguration: APEConfiguration {

    private enum Keys: String {
        case channelToken = "token"
        case hideApesterAds = "noApesterAds"
    }

    public private(set) var channelToken: String
    public private(set) var style: APEStripStyle
    private(set) var hideApesterAds: Bool
    
    override var parameters: [String: String] {
        var value = super.parameters
        value[Keys.channelToken.rawValue] = channelToken
        value[Keys.hideApesterAds.rawValue] = "\(hideApesterAds)"
        return value
    }

    var stripURL: URL? {
        return self.parameters.componentsURL(baseURL: (self.environment.stripBaseUrl + Constants.Strip.stripPath))
    }

    var storyURL: URL? {
        return self.parameters.componentsURL(baseURL: (self.environment.stripBaseUrl + Constants.Strip.stripStoryPath))
    }

    public init(channelToken: String, style: APEStripStyle, bundle: Bundle, environment: APEEnvironment, hideApesterAds: Bool) throws {
        guard !channelToken.isEmpty else {
            throw APEStripConfigurationError.invalidChannelToken
        }
        self.channelToken = channelToken
        self.style = style
        self.hideApesterAds = hideApesterAds
        super.init(bundle: bundle, environment: environment)
    }
    
    public convenience init(channelToken: String, style: APEStripStyle, bundle: Bundle, hideApesterAds: Bool) throws {
        try self.init(channelToken: channelToken, style: style, bundle: bundle, environment: .production, hideApesterAds: hideApesterAds)
    }

    public convenience init(channelToken: String, style: APEStripStyle, bundle: Bundle) throws {
        try self.init(channelToken: channelToken, style: style, bundle: bundle, environment: .production, hideApesterAds: false)
    }
}

// MARK:- Dictionary Extension
extension Dictionary {
    func componentsURL(baseURL urlString: String) -> URL? {
        var components = URLComponents(string: urlString)
        components?.queryItems = self.compactMap { (arg) in
            guard let key = arg.key as? String, let value = arg.value as? String else {
                return nil
            }
            return URLQueryItem(name: key, value: value)
        }
        return components?.url
    }
}
