//
//  ExtensionOptional.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/14/22.
//
import Foundation
///
///
///
internal extension Optional
{
    ///
    ///
    ///
    var demo_isExist: Bool {
        guard case .some = self else { return false }
        return true
    }
}
