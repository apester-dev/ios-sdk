//
//  APEStripswift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/22/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit

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

@objcMembers public class APEStripStyle: NSObject {

    private enum Keys: String {
        case shape          = "itemShape"
        case size           = "itemSize"
        case shadow         = "itemHasShadow"
        case textColor      = "itemTextColor"
        case background     = "stripBackground"
        case paddingTop     = "paddingTop"
        case paddingRight   = "paddingRight"
        case paddingBottom  = "paddingBottom"
        case paddingLeft    = "paddingLeft"
    }

    private var shape: APEStripShape = .roundSquare
    private var size: APEStripSize = .medium
    private var padding: UIEdgeInsets = .zero
    private var shadow: Bool = false
    private var textColor: String?
    private var background: String?

    var parameters: [String: String] {
        var value = [String: String]()
        value[Keys.shape.rawValue]          = shape.value
        value[Keys.size.rawValue]           = size.value
        value[Keys.textColor.rawValue]      = textColor
        value[Keys.background.rawValue]     = background
        value[Keys.shadow.rawValue]         = "\(shadow)"
        value[Keys.paddingTop.rawValue]     = "\(padding.top)"
        value[Keys.paddingRight.rawValue]   = "\(padding.right)"
        value[Keys.paddingBottom.rawValue]  = "\(padding.bottom)"
        value[Keys.paddingLeft.rawValue]    = "\(padding.left)"
        return value
    }

    public init(shape: APEStripShape, size: APEStripSize, padding: UIEdgeInsets, shadow: Bool, textColor: String?, background: String?) {
        self.shape = shape
        self.size = size
        self.shadow = shadow
        self.textColor = textColor
        self.background  = background
        self.padding = padding
    }
}
