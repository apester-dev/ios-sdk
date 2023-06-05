//
//  UserInfoTaggingProtocol.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
// =====================================================================================================================
import Foundation
import XCGLogger
///
///
/// Protocol for creating tagging objects (ie, a tag, a developer, etc) to filter log messages by
public protocol UserInfoTaggingProtocol {
    /// The name of the tagging object
    var name: String { get set }

    /// Convert the object to a userInfo compatible dictionary
    var dictionary: [String: String] { get }

    /// initialize the object with a name
    init(_ name: String)
}
