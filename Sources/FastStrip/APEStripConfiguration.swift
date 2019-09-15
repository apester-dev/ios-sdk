//
//  APEStripConfiguration.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

@objcMembers public class APEStripConfiguration: NSObject {

    @objc public enum APEStripShape: Int {
        case round, square, roundSquare

        var value: String {
            switch self {
            case .round:
                return "round"
            case .square:
                return "square"
            case .roundSquare:
                return "roundSquare"
            @unknown default:
                return ""
            }
        }
    }

    @objc public enum APEStripSize: Int {
        case small, medium, large

        var value: String {
            switch self {
            case .small:
                return "small"
            case .medium:
                return "medium"
            case .large:
                return "large"
            @unknown default:
                return ""
            }
        }
    }

    private enum Keys: String {
        case channelToken = "token"
        case shape = "itemShape"
        case size = "itemSize"
        case shadow = "itemHasShadow"
        case textColor = "itemTextColor"
        case background = "stripBackground"
    }

    private(set) var channelToken: String
    private var bundleInfo: [String : String]
    private var shape: APEStripShape = .roundSquare
    private var size: APEStripSize = .medium
    private var shadow: Bool = false
    private var textColor: String?
    private var background: String?

    private var parameters: [String: String] {
        var value = self.bundleInfo
        value[Keys.channelToken.rawValue] = channelToken
        value[Keys.shape.rawValue] = shape.value
        value[Keys.size.rawValue] = size.value
        value[Keys.shadow.rawValue] = "\(shadow)"
        value[Keys.textColor.rawValue] = textColor
        value[Keys.background.rawValue] = background
        return value
    }

    var url: URL? {
        return self.parameters.componentsURL(baseURL: APEConfig.Strip.stripUrlPath)
    }

    public init(channelToken: String, shape: APEStripShape, size: APEStripSize, shadow: Bool, bundle: Bundle, textColor: String? = nil, background: String? = nil) {
        self.channelToken = channelToken
        self.shape = shape
        self.size = size
        self.shadow = shadow
        self.bundleInfo = APEBundle.bundleInfoPayload(with: bundle)
        self.textColor = textColor
        self.background  = background
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
