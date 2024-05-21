//
//  APEAdProvider.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/7/23.
//
import Foundation
import UIKit
///
///
///
internal protocol APEAdProviderDelegate : AnyObject
{
    var adPresentingViewController: UIViewController? { get }
    func sendNativeGDPREvent(with gdprString: String)
}
internal class APEAdProvider : Equatable
{
    // MARK: - types
    internal enum Status {
        case pending
        case success
        case failure
    }
    
    // MARK: - typealias
    internal typealias HandlerAdType     = (APEMonetization) -> Void
    internal typealias HandlerViewType   = () -> (UIView & APENativeLibraryAdView)?
    internal typealias HandlerVoidType   = () -> Void
    internal typealias HandlerErrorType  = (Error?) -> Void
    internal typealias HandlerContainerType = (APEContainerView) -> Void
    
    // MARK: - Computed properties
    internal var bannerHeight        : CGFloat   { bannerView.creativeHeight }
    internal private(set) var adType : APEAdType
    
    // MARK: - Computed properties - Ad type
    internal var isInUnit         : Bool { adType == .inUnit    }
    internal var isInternalBottom : Bool { adType == .bottom && monetization.isCompanionVariant == false }
    internal var isExternalBottom : Bool { adType == .bottom && monetization.isCompanionVariant == true  }
    internal var isCompanion      : Bool { adType == .companion }
    
    // MARK: - properties
    internal var monetization   : APEMonetization
    internal var nativeDelegate : APENativeLibraryDelegate?
    internal var bannerStatus   : Status
    internal var bannerView     : APEAdView!
    internal var bannerContent  : HandlerViewType
    internal var refresh        : HandlerVoidType
    internal var show           : HandlerContainerType
    internal var hide           : HandlerVoidType
    internal var loaded         : HandlerVoidType?
    internal weak var delegate  : APEAdProviderDelegate?
    
    internal init(
        monetization type: APEMonetization,
        delegate  : APEAdProviderDelegate?
    ) {
        self.bannerStatus  = .pending
        self.monetization  = type
        self.adType        = type.adType
        self.bannerContent = { fatalError() }
        self.refresh       = { fatalError() }
        self.hide          = { fatalError() }
        self.show          = { _ in fatalError() }
    }
    
    internal func statusSuccess() { bannerStatus = .success }
    internal func statusFailure() { bannerStatus = .failure }
}

internal func == (lhs: APEAdProvider, rhs: APEAdProvider) -> Bool {
    let lt = lhs.monetization
    let rt = rhs.monetization
    return lt.identifier == rt.identifier && lt.adType == rt.adType && lt.isCompanionVariant == rt.isCompanionVariant
}
