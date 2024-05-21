//
//  APEAdSize.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//
import Foundation
///
///
///
internal enum APEAdSize : String , CustomStringConvertible
{
    case adSize320x50  = "Size: 320x50"
    case adSize300x250 = "Size: 300x250"
    case adSize320x480 = "Size: 320x480"
    
    internal var size : CGSize {
        switch self {
        case .adSize320x50 : return .init(width: 320, height: 50)
        case .adSize300x250: return .init(width: 300, height: 250)
        case .adSize320x480: return .init(width: 320, height: 480)
        }
    }
    
    internal var description : String { rawValue }
}
