//
//  APEAdMobStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
///
///
///
@objc(APEAdMobStrategy)
@objcMembers
final public class APEAdMobStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.adMob
    }
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEAdMobAdParameters.init(from: dictionary)
    }
    internal override func createAdProvider(
        params                      : APEAdParameters,
        delegate                    : APEAdProviderDelegate,
        adTitleLabelText            : String,
        inUnitBackgroundColor       : UIColor,
        GDPRConsent gdprString      : String?,
        onAdRemovalCompletion       : @escaping APEAdProvider.HandlerAdType,
        onAdRequestedCompletion     : @escaping APEAdProvider.HandlerVoidType,
        receiveAdSuccessCompletion  : @escaping APEAdProvider.HandlerVoidType,
        receiveAdErrorCompletion    : @escaping APEAdProvider.HandlerErrorType
    ) -> APEAdProvider {
        
        let parameters = params as! APEAdMobAdParameters
        
        return APEAdProvider.adMobProvider(
            params                      : parameters,
            delegate                    : delegate,
            adTitleLabelText	        : adTitleLabelText,
            inUnitBackgroundColor	    : inUnitBackgroundColor,
            GDPRConsent                 : gdprString,
            onAdRemovalCompletion       : onAdRemovalCompletion,
            onAdRequestedCompletion     : onAdRequestedCompletion,
            receiveAdSuccessCompletion  : receiveAdSuccessCompletion,
            receiveAdErrorCompletion    : receiveAdErrorCompletion
        )
    }
}
