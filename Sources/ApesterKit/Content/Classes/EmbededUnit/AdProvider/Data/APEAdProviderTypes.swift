//
//  APEAdProviderTypes.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/26/23.
//
import Foundation
///
///
///
internal enum APEAdProviderType : String , CustomStringConvertible {
    case adMob    = "adMob"
    case pubmatic = "pubmatic"
    case amazon   = "amazon"
    case aniview  = "aniview_native"
    var description : String { rawValue }
}
