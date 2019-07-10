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

    public var channelToken: String
    public var shape: Shape = .roundSquare
    public var size: Size = .medium
    public var shadow: Bool = false
    public var textColor: String?
    public var background: String?


    public init(channelToken: String, shape: Shape, size: Size, shadow: Bool, textColor: String? = nil, background: String? = nil) {
        self.channelToken = channelToken
        self.shape = shape
        self.size = size
        self.shadow = shadow
        self.textColor = textColor
        self.background  = background
    }

    var dictionary: [String: String] {
        var value = [String: String]()
        value["token"] = channelToken
        value["itemShape"] = shape.rawValue
        value["itemSize"] = size.rawValue
        value["itemHasShadow"] = "\(shadow)"
        value["itemTextColor"] = textColor ?? ""
        value["stripBackground"] = background ?? ""
        return value
    }
}
