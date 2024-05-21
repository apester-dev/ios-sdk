//
//  APENativeLibrary.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//
import Foundation
import UIKit
///
///
///
internal protocol APENativeLibraryAdView
{
    var nativeSize : CGSize { get }
    func forceRefreshAd()
    func proceedToTriggerLoadAd()
}

@objc
@objcMembers
internal class APENativeLibraryDelegate : NSObject , APEBiddingManagerDelegate
{
    internal weak  var containerViewController: UIViewController?
    internal weak private(set) var adProvider : APEAdProvider?
    internal private(set) var receiveAdSuccess: APEAdProvider.HandlerVoidType
    internal private(set) var receiveAdError  : APEAdProvider.HandlerErrorType
    internal private(set) var adLoaded        : APEAdProvider.HandlerVoidType?
    internal private(set) var biddingManager  : APEBiddingManager
    init(
        adProvider provider     : APEAdProvider,
        container viewController: UIViewController?,
        receiveAdSuccess success: @escaping APEAdProvider.HandlerVoidType,
        receiveAdError     error: @escaping APEAdProvider.HandlerErrorType
    ) {
        self.adProvider              = provider
        self.containerViewController = viewController
        self.receiveAdSuccess = success
        self.receiveAdError = error
        self.biddingManager = APEBiddingManager()
        super.init()
        self.biddingManager.delegate = self
    }
    
    init(
        adProvider provider     : APEAdProvider,
        container viewController: UIViewController?,
        receiveAdSuccess success: @escaping APEAdProvider.HandlerVoidType,
        receiveAdError     error: @escaping APEAdProvider.HandlerErrorType,
        adLoaded          onLoad: @escaping APEAdProvider.HandlerVoidType
    ) {
        self.adProvider              = provider
        self.containerViewController = viewController
        self.receiveAdSuccess = success
        self.receiveAdError = error
        self.adLoaded = onLoad
        self.biddingManager = APEBiddingManager()
        super.init()
        self.biddingManager.delegate = self
    }
    
    // MARK: - APEBiddingManagerDelegate
    
    @objc func didReceiveResponse(_ response: [String : Any]?)
    {
        // NO OP - override location
    }
    
    @objc func didFail(toReceiveResponse error: Error?)
    {
        // NO OP - override location
    }
}
