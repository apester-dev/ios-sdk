//
//  APEAdProviderLoader.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import ApesterObjcBridging
///
///
///
@objc(APEAdProviderLoader)
@objcMembers
internal class APEAdProviderLoader : NSObject
{
    
    internal static func setupAdProvider(for controller: APEUnitController, basedOn dictionary: [String: Any])
    {
        let strategies = availableStrategies(for: controller)
        
        strategies.forEach {
            $0.setupAdProvider(basedOn: dictionary)
        }
    }
}
private extension APEAdProviderLoader
{
    private static func availableStrategies(
        for controller: APEUnitController
    ) ->  [APEAdProviderStrategyProtocol] {
        // Maks sure to test for amazon first, due to a non-standard parsing
        return [
            amazonStrategy  (for: controller),
            pubmaticStrategy(for: controller),
            adMobStrategy   (for: controller),
            aniviewStrategy (for: controller)
        ].compactMap { $0 }
    }
    
    private static func adMobStrategy(for controller: APEUnitController) -> APEAdProviderStrategyProtocol?
    {
        let strategy = APEApesterObjcBridging.instantiateClassNamed(
            withObject: "APEAdMobStrategy",
            selectorName: "initWithUnitController:",
            with: controller) as? APEAdProviderStrategyProtocol
        return strategy
    }
    private static func amazonStrategy(for controller: APEUnitController) -> APEAdProviderStrategyProtocol?
    {
        let strategy = APEApesterObjcBridging.instantiateClassNamed(
            withObject: "APEAmazonStrategy",
            selectorName: "initWithUnitController:",
            with: controller) as? APEAdProviderStrategyProtocol
        return strategy
    }
    private static func pubmaticStrategy(for controller: APEUnitController) -> APEAdProviderStrategyProtocol?
    {
        let strategy = APEApesterObjcBridging.instantiateClassNamed(
            withObject: "APEPubMaticStrategy",
            selectorName: "initWithUnitController:",
            with: controller) as? APEAdProviderStrategyProtocol
        return strategy
    }
    private static func aniviewStrategy(for controller: APEUnitController) -> APEAdProviderStrategyProtocol?
    {
        let strategy = APEApesterObjcBridging.instantiateClassNamed(
            withObject: "APEAniViewStrategy",
            selectorName: "initWithUnitController:",
            with: controller) as? APEAdProviderStrategyProtocol
        return strategy
    }
}
