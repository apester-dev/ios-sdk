//
//  APEAdParameters.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//

import Foundation

internal protocol APEAdParameters
{
    var identifier : String    { get }
    var isVariant  : Bool      { get }
    var type       : APEAdType { get }
}
