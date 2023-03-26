//
//  Constants.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

struct Constants
{
    /// Payload Keys
    struct Payload
    {
        static let advertisingId = "advertisingId"
        static let trackingEnabled = "trackingEnabled"
        static let bundleId = "bundleId"
        static let appName = "appName"
        static let appVersion = "appVersion"
        static let appStoreUrl = "appStoreUrl"
        static let sdkVersion = "sdkVersion"
    }

    /// WebView shared functions or keys
    struct WebView
    {
        static let apesterAdsCompleted = "apester_ads_completed"
        // functions
        static let close = "window.__closeApesterStory()"
        //
        static func sendApesterEvent(with message: String) -> String {
            "window.__sendApesterEvent(\(message))"
        }
        //
        static func setViewVisibilityStatus(_ isVisible: Bool) -> String {
            "window.__setApesterViewabiity(\(isVisible))"
        }
        //
        static let getHeight = "window.__getHeight()"
        static let refreshContent = "window.__refreshApesterContent()"
        static let pause = "window.__storyPause()"
        static let resume = "window.__storyResume()"
        static let restart = "window.__storyRestart()"
        static let fullscreenOff = "fullscreen_off"
    }

    /// Strip Keys
    struct Strip
    {
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
    }
    
    struct Unit
    {
        static let isReady = "apester_interaction_loaded"
        static let inAppUnitDetached = "in-app-unit-detached"
        static let unitPath = "/v2/static/\(inAppUnitDetached).html"
        static let proxy = "apesterUnitProxy"
        static let resize = "apester_resize_unit"
        static let height = "height"
        static let width = "width"
        static let validateUnitViewVisibility = "validateUnitViewVisibity"
        static let initInAppParams = "init_inapp_params"
    }
    
    struct Monetization
    {
        static let adMob            = "adMob"
        static let pubMatic         = "pubMatic"
        static let amazon           = "amazon"
        static let profileId        = "iosProfileId"
        static let adProvider       = "provider"
        static let publisherId      = "publisherId"
        static let appStoreUrl      = "iosAppStoreUrl"
        static let initNativeAd     = "apester_init_native_ad"
        static let initInUnit       = "apester_init_inunit"
        static let killInUnit       = "apester_kill_native_ad"
        static let adUnitId         = "iosAdUnitId"
        static let isVariant        = "isCompanionVariant"
        static let adType           = "adType"
        static let appDomain        = "appDomain"
        static let testMode         = "testMode"
        static let debugLogs        = "debugLogs"
        static let bidSummaryLogs   = "bidSummaryLogs"
        static let timeInView       = "timeInView"
    }
    
    struct Analytics
    {
        static let playerMonImpression              = "player_mon_impression"
        static let playerMonLoadingPass             = "player_mon_loading_pass"
        static let playerMonImpressionPending       = "player_mon_impression_pending"
        static let playerMonLoadingImpressionFailed = "player_mon_loading_impression_failed"
    }
}
