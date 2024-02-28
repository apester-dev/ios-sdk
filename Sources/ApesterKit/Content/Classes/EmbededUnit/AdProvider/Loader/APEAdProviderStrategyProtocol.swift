//
//  APEAdProviderStrategyProtocol.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
///
///
///
@objc(APEAdProviderStrategyProtocol)
public protocol APEAdProviderStrategyProtocol : NSObjectProtocol
{
    init(unitController: APEUnitController)
    
    @discardableResult func setupAdProvider(basedOn dictionary: [String: Any]) -> Bool
}
