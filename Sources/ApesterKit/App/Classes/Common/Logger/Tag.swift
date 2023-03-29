//
//  Tag.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
// =====================================================================================================================
import Foundation
import XCGLogger
///
///
/// Struction for tagging log messages with Tags
public struct Tag: UserInfoTaggingProtocol {

    /// The name of the tag
    public var name: String

    /// Dictionary representation compatible with the userInfo paramater of log messages
    public var dictionary: [String: String] {
        return [XCGLogger.Constants.userInfoKeyTags: name]
    }

    /// Initialize a Tag object with a name
    public init(_ name: String) {
        self.name = name
    }

    /// Create a Tag object with a name
    public static func name(_ name: String) -> Tag {
        return Tag(name)
    }

    /// Generate a userInfo compatible dictionary for the array of tag names
    public static func names(_ names: String...) -> [String: [String]] {
        var tags: [String] = []

        for name in names {
            tags.append(name)
        }

        return [XCGLogger.Constants.userInfoKeyTags: tags]
    }
}
