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

@objcMembers public class APEStripConfiguration: NSObject {

    private enum Keys: String {
        case channelToken   = "token"
    }

    public private(set) var channelToken: String
    public private(set) var style: APEStripStyle
    private(set) var bundleInfo: [String : String]

    private var parameters: [String: String] {
        var value = self.bundleInfo.merging(self.style.parameters, uniquingKeysWith: { $1 })
        value[Keys.channelToken.rawValue] = channelToken
        return value
    }

    var url: URL? {
        return self.parameters.componentsURL(baseURL: Constants.Strip.stripUrlPath)
    }

    public init(channelToken: String, style: APEStripStyle, bundle: Bundle) throws {
        guard !channelToken.isEmpty else {
            throw APEStripConfigurationError.invalidChannelToken
        }
        self.channelToken = channelToken
        self.style = style
        self.bundleInfo = BundleInfo.bundleInfoPayload(with: bundle)
    }
}

// MARK:- Dictionary Extension
private extension Dictionary {
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
