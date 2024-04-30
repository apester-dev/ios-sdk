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
@objc
@objcMembers
internal class APENativeVideoLibraryDelegate : APENativeLibraryDelegate {
    
    internal private(set) var videoComplete  : APEAdProvider.HandlerVoidType
    internal weak  var container: UIViewController?
    internal weak private(set) var vidProvider : APEAdProvider?
    internal private(set) var onReceiveAdSuccess: APEAdProvider.HandlerVoidType
    internal private(set) var onReceiveAdError  : APEAdProvider.HandlerErrorType

    init(videoComplete: @escaping APEAdProvider.HandlerVoidType, containerVC: UIViewController?, adProvider: APEAdProvider, receiveAdSuccess: @escaping APEAdProvider.HandlerVoidType, receiveAdError: @escaping APEAdProvider.HandlerErrorType) {
        self.videoComplete = videoComplete
        self.container = containerVC
        self.vidProvider = adProvider
        self.onReceiveAdSuccess = receiveAdSuccess
        self.onReceiveAdError = receiveAdError
        super.init(adProvider: adProvider, container: containerVC, receiveAdSuccess: receiveAdSuccess, receiveAdError: receiveAdError)
    }
    
}
