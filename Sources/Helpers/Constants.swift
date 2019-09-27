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
        static let appStoreUrl = "appStoreUrl"
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
        static let baseUrl = "https://faststrip.apester.com"
        static let stripUrlPath = baseUrl + "/apester-detatched-strip.html"
        static let stripStoryUrlPath = baseUrl + "/apester-detatched-story.html"
        //
        static let apester = "apester.com"
        static let blank = "about:blank"
        static let safeframe = "safeframe"
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
        // functions
        static func sendApesterEvent(with message: String) -> String {
            return "window.__sendApesterEvent(" + message + ")"
        }
        static let getHeight = "window.__getHeight()"
        static let getUserAgent = "navigator.userAgent"
    }
}
