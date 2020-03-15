//
//  Constants.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

struct Constants {
    /// Payload Keys
    struct Payload {
        static let advertisingId = "advertisingId"
        static let trackingEnabled = "trackingEnabled"
        static let bundleId = "bundleId"
        static let appName = "appName"
        static let appVersion = "appVersion"
        static let appStoreUrl = "appStoreUrl"
        static let sdkVersion = "sdkVersion"
    }

    /// WebView Keys
    struct WebView {
        static let loadCallbackFileName = "loadCallbackJS.text"
        static let initAdevrtisingParamsFunctionName = "initAdvertisingParams"
        static let registerJSFileName = "registerJS.text"
        static let callbackFunction = "apesterCallback"
        static let callback = "apesterKitCallback"
    }

    /// Strip Keys
    struct Strip {
        // urls
        static let stripPath = "/apester-detatched-strip.html"
        static let stripStoryPath = "/apester-detatched-story.html"
        // events
        static let proxy = "apesterStripProxy"
        static let initial = "apester_strip_units"
        static let loaded = "strip_loaded"
        static let isReady = "apester_interaction_loaded"
        static let open = "strip_open_unit"
        static let next = "strip_next_unit"
        static let off = "fullscreen_off"
        static let destroy = "apester_strip_removed"
        static let showStripStory = "showApesterStory"
        static let hideStripStory = "hideApesterStory"
        static let stripHeight = "mobileStripHeight"
        static let stripResizeHeight = "strip_resize"
        static let validateStripViewVisibity = "validateStripViewVisibity"
        // functions
        static let close = "window.__closeApesterStory()"
        //
        static func sendApesterEvent(with message: String) -> String {
            return "window.__sendApesterEvent(\(message))"
        }
        //
        static func setViewVisibilityStatus(_ isVisible: Bool) -> String {
            return "window.__setApesterViewabiity(\(isVisible))"
        }
        //
        static let getHeight = "window.__getHeight()"
    }
    
    struct Unit {
        static let unitPath = "/v2/static/in-app-unit-detached.html"
        static let proxy = "apesterUnitProxy"
        static let resize = "apester_resize_unit"
        static let height = "height"
        static let width = "width"
        static let validateStripViewVisibity = "validateStripViewVisibity"
        static func setViewVisibilityStatus(_ isVisible: Bool) -> String {
            return "window.__setApesterViewabiity(\(isVisible))"
        }
    }
}
