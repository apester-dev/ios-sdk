//
//  Constants.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
///
///
///
internal struct Constants
{
    /// Payload Keys
    internal struct Payload
    {
        internal static let advertisingId = "advertisingId"
        internal static let trackingEnabled = "trackingEnabled"
        internal static let bundleId = "bundleId"
        internal static let appName = "appName"
        internal static let appVersion = "appVersion"
        internal static let appStoreUrl = "appStoreUrl"
        internal static let sdkVersion = "sdkVersion"
    }

    /// WebView shared functions or keys
    internal struct WebView
    {
        internal static let apesterAdsCompleted = "apester_ads_completed"
        // functions
        internal static let close = "window.__closeApesterStory()"
        //
        internal static func sendApesterEvent(with message: String) -> String {
            "window.__sendApesterEvent(\(message))"
        }
        //
        internal static func setViewVisibilityStatus(_ isVisible: Bool) -> String {
            "window.__setApesterViewabiity(\(isVisible))"
        }
        //
        internal static let getHeight = "window.__getHeight()"
        internal static let refreshContent = "window.__refreshApesterContent()"
        internal static let pause = "window.__storyPause()"
        internal static let resume = "window.__storyResume()"
        internal static let restart = "window.__storyRestart()"
        internal static let fullscreenOff = "fullscreen_off"
    }

    /// Strip Keys
    internal struct Strip
    {
        // urls
        internal static let stripPath = "/apester-detatched-strip.html"
        internal static let stripStoryPath = "/apester-detatched-story.html"
        // events
        internal static let proxy = "apesterStripProxy"
        internal static let initial = "apester_strip_units"
        internal static let loaded = "strip_loaded"
        internal static let isReady = "apester_interaction_loaded"
        internal static let open = "strip_open_unit"
        internal static let next = "strip_next_unit"
        internal static let off = "fullscreen_off"
        internal static let destroy = "apester_strip_removed"
        internal static let showStripStory = "showApesterStory"
        internal static let hideStripStory = "hideApesterStory"
        internal static let stripHeight = "mobileStripHeight"
        internal static let stripResizeHeight = "strip_resize"
        internal static let validateStripViewVisibity = "validateStripViewVisibity"
    }
    
    internal struct Unit
    {
        internal static let isReady = "apester_interaction_loaded"
        internal static let inAppUnitDetached = "in-app-unit-detached"
        internal static let unitPath = "/v2/static/\(inAppUnitDetached).html"
        internal static let debugQuery = "?__APESTER_DEBUG__=true"
        internal static let proxy = "apesterUnitProxy"
        internal static let resize = "apester_resize_unit"
        internal static let height = "height"
        internal static let width = "width"
        internal static let validateUnitViewVisibility = "validateUnitViewVisibity"
        internal static let initInAppParams = "init_inapp_params"
    }
    
    internal struct Monetization
    {
        internal static let adMob            = "adMob"
        internal static let pubMatic         = "pubMatic"
        internal static let amazon           = "amazon"
        internal static let profileId        = "iosProfileId"
        internal static let adProvider       = "provider"
        internal static let publisherId      = "publisherId"
        internal static let appStoreUrl      = "iosAppStoreUrl"
        internal static let initNativeAd     = "apester_init_native_ad"
        internal static let initInUnit       = "apester_init_inunit"
        internal static let killInUnit       = "apester_kill_native_ad"
        internal static let adUnitId         = "iosAdUnitId"
        internal static let isVariant        = "isCompanionVariant"
        internal static let adType           = "adType"
        internal static let appDomain        = "appDomain"
        internal static let testMode         = "testMode"
        internal static let debugLogs        = "debugLogs"
        internal static let bidSummaryLogs   = "bidSummaryLogs"
        internal static let timeInView       = "timeInView"
    }
    
    internal struct Analytics
    {
        internal static let playerMonImpression              = "player_mon_impression"
        internal static let playerMonLoadingPass             = "player_mon_loading_pass"
        internal static let playerMonImpressionPending       = "player_mon_impression_pending"
        internal static let playerMonLoadingImpressionFailed = "player_mon_loading_impression_failed"
    }
}
