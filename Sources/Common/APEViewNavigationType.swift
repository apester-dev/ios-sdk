//
//  APEViewNavigationType.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 3/19/20.
//  Copyright © 2020 Apester. All rights reserved.
//

import Foundation

#if os(iOS)
@available(iOS 11.0, *)

/// This enum describes the link type was activated.
@objc public enum APEViewNavigationType: Int {
    /// Navigation is taking place for some other reason.
    case other
    /// A link with an href attribute was activated by the user.
    case linkActivated
    /// A link for a scoial media was activated by the user.
    case shareLinkActivated
}

#endif
