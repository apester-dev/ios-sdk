//
//  APEStripParams.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

public struct APEStripParams {
    public enum Shape: String {
        case round, square, roundSquare
    }

    public enum Size: String {
        case small, medium, large
    }

    private var channelToken: String
    private var bundleInfo: [String : String]
    private var shape: Shape = .roundSquare
    private var size: Size = .medium
    private var shadow: Bool = false
    private var textColor: String?
    private var background: String?

    private var parameters: [String: String] {
        var value = [String: String]()
        value["token"] = channelToken
        value["itemShape"] = shape.rawValue
        value["itemSize"] = size.rawValue
        value["itemHasShadow"] = "\(shadow)"
        value["itemTextColor"] = textColor ?? ""
        value["stripBackground"] = background ?? ""
        return value + self.bundleInfo
    }

    var url: URL? {
        return self.parameters.componentsURL(baseURL: APEConfig.Strip.stripUrlPath)
    }

    public init(channelToken: String, shape: Shape, size: Size, shadow: Bool, bundle: Bundle, textColor: String? = nil, background: String? = nil) {
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

    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
}
