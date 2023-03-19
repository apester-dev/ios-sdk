//
//  APENativeLibrary.swift
//  ApesterKit
//
//  Created by Arkadi Yoskovitz on 3/8/23.
//

import UIKit

internal protocol APENativeLibraryAdView
{
    var nativeSize : CGSize { get }
    func forceRefreshAd()
}

internal class APENativeLibraryDelegate : NSObject
{
    internal weak  var containerViewController: UIViewController?
    internal private(set) var receiveAdSuccess: APEAdProvider.HandlerVoidType
    internal private(set) var receiveAdError  : APEAdProvider.HandlerErrorType

    init(
        container viewController: UIViewController?,
        receiveAdSuccess success: @escaping APEAdProvider.HandlerVoidType,
        receiveAdError     error: @escaping APEAdProvider.HandlerErrorType
    ) {
        self.containerViewController = viewController
        self.receiveAdSuccess = success
        self.receiveAdError = error
    }
}
