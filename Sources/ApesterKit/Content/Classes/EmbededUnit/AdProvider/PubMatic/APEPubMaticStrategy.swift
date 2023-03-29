//
//  APEPubMaticStrategy.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/27/23.
//
import Foundation
import UIKit
import OSLog
///
///
///
@objc(APEPubMaticStrategy)
@objcMembers
final public class APEPubMaticStrategy : APEAdProviderStrategy
{
    // MARK: - Properties - Computed
    internal override var strategyType : APEAdProviderType
    {
        return APEAdProviderType.pubmatic
    }
    // MARK: - utilities - internal
    internal override func generateAdParameters(
        form dictionary: [String: Any]
    ) -> APEAdParameters? {
        return APEPubMaticAdParameters.init(from: dictionary)
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
        
        let parameters = params as! APEPubMaticAdParameters
        
        publishGDPR(basedOn: parameters, GDPRConsent: gdprString, delegate: delegate)
        
        return APEAdProvider.pubMaticProvider(
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
    
    private func publishGDPR(
        basedOn parameters    : APEPubMaticAdParameters,
        GDPRConsent gdprString: String?,
        delegate              : APEAdProviderDelegate
    ) {
        guard parameters.testMode  else { return }
        guard parameters.debugLogs else { return }
        
        guard let gdpr = gdprString else { return }
        os_log("ApeSterSDK::-GDPR-String-: %{public}@", log: OSLog.ApesterSDK, type: .debug, gdpr)
        delegate.sendNativeGDPREvent(with: gdpr)
    }
}
