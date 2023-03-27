//
//  APEStripswift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/22/19.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
import UIKit
///
///
///
@objc(APEStripShape)
public enum APEStripShape: Int {
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

@objc(APEStripSize)
public enum APEStripSize: Int {
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

@objc(APEStripHeader)
@objcMembers
public class APEStripHeader: NSObject {

    private enum Keys: String {
        case text    = "headerText"
        case size    = "headerFontSize"
        case family  = "headerFontFamily"
        case weight  = "headerFontWeight"
        case color   = "headerFontColor"
        case isLTR   = "headerLtr"
        case padding = "horizontalHeaderPadding"
    }

    private let text    : String
    private let size    : CGFloat
    private let weight  : Int
    private let isLTR   : Bool
    private let horizontalPadding: CGFloat
    private let family  : String?
    private let color   : UIColor?

    fileprivate var parameters: [String: String] {
        var value = [String: String]()
        value[Keys.text.rawValue]       = self.text
        value[Keys.padding.rawValue]    = "\(self.horizontalPadding)"
        value[Keys.size.rawValue]       = "\(self.size)"
        value[Keys.isLTR.rawValue]      = "\(self.isLTR)"
        value[Keys.weight.rawValue]     = "\(self.weight)"
        value[Keys.family.rawValue]     = self.family != nil ? "\(self.family!)" : nil
        value[Keys.color.rawValue]      = self.color != nil ? "\(self.color!.rgba)" : nil
        return value
    }

    public init(text: String, size: CGFloat, family: String?, weight: Int, color: UIColor?, isLTR: Bool, horizontalPadding: CGFloat) {
        self.text = text
        self.size = size
        self.family = family
        self.weight = weight
        self.color = color
        self.isLTR = isLTR
        self.horizontalPadding = horizontalPadding
    }

    public convenience init(text: String, size: CGFloat, family: String?, weight: Int, color: UIColor?, horizontalPadding: CGFloat) {
        self.init(text: text, size: size, family: family, weight: weight, color: color, isLTR: true, horizontalPadding: horizontalPadding)
    }

    public convenience init(text: String, size: CGFloat, family: String?, weight: Int, color: UIColor?) {
        self.init(text: text, size: size, family: family, weight: weight, color: color, horizontalPadding: 0)
    }
}

@objc(APEStripStyle)
@objcMembers
public class APEStripStyle: NSObject {

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

    private let shape: APEStripShape
    private let size: APEStripSize
    private let padding: UIEdgeInsets
    private let shadow: Bool
    private let textColor: UIColor?
    private let backgroundColor: UIColor?
    private let header: APEStripHeader?

    var parameters: [String: String] {
        var value = [:].merging(self.header?.parameters ?? [:], uniquingKeysWith: { $1 })
        value[Keys.shape.rawValue]          = shape.value
        value[Keys.size.rawValue]           = size.value
        value[Keys.textColor.rawValue]      = textColor?.rgba
        value[Keys.background.rawValue]     = backgroundColor?.rgba
        value[Keys.shadow.rawValue]         = "\(shadow)"
        value[Keys.paddingTop.rawValue]     = "\(padding.top)"
        value[Keys.paddingRight.rawValue]   = "\(padding.right)"
        value[Keys.paddingBottom.rawValue]  = "\(padding.bottom)"
        value[Keys.paddingLeft.rawValue]    = "\(padding.left)"
        return value
    }

    public init(shape: APEStripShape, size: APEStripSize, padding: UIEdgeInsets, shadow: Bool, textColor: UIColor?, background: UIColor?, header: APEStripHeader?) {
        self.shape = shape
        self.size = size
        self.padding = padding
        self.shadow = shadow
        self.textColor = textColor
        self.backgroundColor = background
        self.header = header
    }

    public convenience init(shape: APEStripShape, size: APEStripSize, padding: UIEdgeInsets, shadow: Bool, textColor: UIColor?, background: UIColor?) {
        self.init(shape: shape, size: size, padding: padding, shadow: shadow, textColor: textColor, background: background, header: nil)
    }
}
