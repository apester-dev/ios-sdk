//
//  APEStripServiceDelegate.swift
//  ApesterKit
//
//  Created by Hasan Sa on 10/07/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import CoreGraphics

/// Handling The Apester Story Unit presentation
public protocol APEStripServiceDelegate: AnyObject {
    func stripComponentIsReady(unitHeight height: CGFloat)
    func displayStoryComponent()
    func hideStoryComponent()
}

/// Observing The Apester Story Unit show / hide events.
public protocol APEStripServiceDataSource: AnyObject {
    var showStoryFunction: String { get }
    var hideStoryFunction: String { get }
}
