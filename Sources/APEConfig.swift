//
//  APEConfig.swift
//  ApesterKit
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation

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
    static let proxy = "apesterStripProxy"
    static let stripFileName = "apester-strip.html"
    static let initial = "apester_strip_units"
    static let loaded = "strip_loaded"
    static let open = "strip_open_unit"
    static let next = "strip_next_unit"
    static let stripStoryFileName = "apester-strip-story.html"
    static let showStripStory = "showApesterStory"
    static let hideStripStory = "hideApesterStory"

    // local HTML token parameter - to be removed
    static let dataChannelTokens = "data-channel-tokens"
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
}
