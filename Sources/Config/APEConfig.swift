//
//  APEConfig.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import AdSupport

struct APEConfig {
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
    static let stripUrlPath = "https://faststrip.apester.com/apester-detatched-strip.html"
    static let stripStoryUrlPath = "https://faststrip.apester.com/apester-detatched-story.html"
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
  }
}

// strip loaded

/// Kit Bundle
class APEBundle {
  static let bundleName = "ApesterKit.bundle"

  static var bundle: Bundle {
    let klass: AnyClass = object_getClass(self)!
    return Bundle(for: klass)
  }

  static func contentsOfFile(_ file: String) -> String {
    // load js bundle file
    if let bundleResourcePath = bundle.resourcePath {
      let path = "\(bundleResourcePath)/\(APEBundle.bundleName)/\(file)"
      let data = NSData(contentsOfFile: path)
      if let fileData = data as Data? {
        if let result = String(data: fileData, encoding: String.Encoding.utf8) {
          return result
        }
      }
    }
    return ""
  }

  // the deviceInfoParamsDictionary settings data
  static func bundleInfoPayload(with bundle: Bundle?) -> [String: String] {
    var deviceInfoPayload: [String: String] = [:]

    // get the device advertisingIdentifier
    let identifierManager = ASIdentifierManager.shared()
    let idfa = identifierManager.advertisingIdentifier
    deviceInfoPayload[APEConfig.Payload.advertisingId] = idfa.uuidString
    deviceInfoPayload[APEConfig.Payload.trackingEnabled] = "\(identifierManager.isAdvertisingTrackingEnabled)"

    if let bundle = bundle {
      // get the app bundleIdentifier
      if let bundleIdentifier = bundle.bundleIdentifier {
        deviceInfoPayload[APEConfig.Payload.bundleId] = bundleIdentifier
      }
      // get the app name and
      if let infoDictionary = bundle.infoDictionary,
        let appName = infoDictionary[kCFBundleNameKey as String] as? String {
        deviceInfoPayload[APEConfig.Payload.appName] = appName
        deviceInfoPayload[APEConfig.Payload.appStoreUrl] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
      }
    }
    return deviceInfoPayload
  }
}
