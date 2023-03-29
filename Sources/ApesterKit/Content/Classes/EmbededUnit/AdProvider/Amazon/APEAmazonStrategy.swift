//
//  APEAmazonStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
///
///
///
@objc(APEAmazonStrategy)
@objcMembers
final public class APEAmazonStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.amazon
    }
    
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEAmazonAdParameters.init(from: dictionary)
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
        
        let parameters = params as! APEAmazonAdParameters

        return APEAdProvider.amazonProvider(
            params                      : parameters,
            delegate                    : delegate,
            adTitleLabelText            : adTitleLabelText,
            inUnitBackgroundColor       : inUnitBackgroundColor,
            GDPRConsent                 : gdprString,
            onAdRemovalCompletion       : onAdRemovalCompletion,
            onAdRequestedCompletion     : onAdRequestedCompletion,
            receiveAdSuccessCompletion  : receiveAdSuccessCompletion,
            receiveAdErrorCompletion    : receiveAdErrorCompletion
        )
    }
}
