//
//  BundleInfo.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/27/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import AdSupport

/// BundleInfo
class BundleInfo {
    static let bundleName = "ApesterKit.bundle"

    static var bundle: Bundle {
        let klass: AnyClass = object_getClass(self)!
        return Bundle(for: klass)
    }

    static func contentsOfFile(_ file: String) -> String {
        // load js bundle file
        if let bundleResourcePath = bundle.resourcePath {
            let path = "\(bundleResourcePath)/\(BundleInfo.bundleName)/\(file)"
            let data = NSData(contentsOfFile: path)
            if let fileData = data as Data?, let result = String(data: fileData, encoding: String.Encoding.utf8) {
                return result
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
        deviceInfoPayload[Constants.Payload.advertisingId] = idfa.uuidString
        deviceInfoPayload[Constants.Payload.trackingEnabled] = "\(identifierManager.isAdvertisingTrackingEnabled)"

        if let bundle = bundle {
            // get the app bundleIdentifier
            if let bundleIdentifier = bundle.bundleIdentifier {
                deviceInfoPayload[Constants.Payload.bundleId] = bundleIdentifier
            }
            // get the app name and
            if let infoDictionary = bundle.infoDictionary, let appName = infoDictionary[kCFBundleNameKey as String] as? String {
                deviceInfoPayload[Constants.Payload.appName] = appName
                deviceInfoPayload[Constants.Payload.appStoreUrl] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
            }
        }
        return deviceInfoPayload
    }
}
