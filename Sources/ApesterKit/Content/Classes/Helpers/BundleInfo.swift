//
//  BundleInfo.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/27/19.
//  Copyright © 2019 Apester. All rights reserved.
//
import Foundation
import AdSupport
import AppTrackingTransparency
///
///
///
/// BundleInfo
internal class BundleInfo
{    
    internal static let bundleName = "ApesterKit.bundle"

    internal static var bundle : Bundle
    {
        let klass: AnyClass = object_getClass(self)!
        return Bundle(for: klass)
    }

    internal static func contentsOfFile(_ file: String) -> String
    {
        // load js bundle file
        guard let bundleResourcePath = bundle.resourcePath else { return "" }
        
        let path = "\(bundleResourcePath)/\(BundleInfo.bundleName)/\(file)"
        
        let data = NSData(contentsOfFile: path)
        
        guard let fileData = data as Data? else { return "" }
        guard let result = String(data: fileData, encoding: String.Encoding.utf8) else { return "" }
        
        return result
    }

    // the deviceInfoParamsDictionary settings data
    internal static func bundleInfoPayload(with bundle: Bundle?) -> [String: String]
    {
       
        var deviceInfoPayload: [String: String] = [:]
        // get the device advertisingIdentifier
        let identifierManager = ASIdentifierManager.shared()
        if identifierManager.isAdvertisingTrackingEnabled {
            print("advertising tracking is enabled ")
        } else {
            print("advertising tracking is disabled")
        }
        let idfa = identifierManager.advertisingIdentifier
        deviceInfoPayload[Constants.Payload.advertisingId] = idfa.uuidString
        deviceInfoPayload[Constants.Payload.trackingEnabled] = "\(identifierManager.isAdvertisingTrackingEnabled)"

        if let bundle = bundle {
            // get the app bundleIdentifier
            if let bundleIdentifier = bundle.bundleIdentifier {
                deviceInfoPayload[Constants.Payload.bundleId] = bundleIdentifier
            }
            // get the app name and the app version
            if let infoDictionary = bundle.infoDictionary {
                if let appName = infoDictionary[kCFBundleNameKey as String] as? String {
                    deviceInfoPayload[Constants.Payload.appName] = appName
                    deviceInfoPayload[Constants.Payload.appStoreUrl] = "https://appstore.com/\(appName.trimmingCharacters(in: .whitespaces))"
                }
                var appVersion = ""
                if let value = infoDictionary["CFBundleShortVersionString"] as? String {
                    appVersion += value
                }
                if let value = infoDictionary[kCFBundleVersionKey as String] as? String {
                    let version: (String) -> String = (appVersion.isEmpty) ? { $0 } : { "(\($0))" }
                    appVersion += (version(value))
                }
                deviceInfoPayload[Constants.Payload.appVersion] = appVersion
            }
            // get the SDK version
            if let infoDictionary = Bundle(for: Self.self).infoDictionary,
                let sdkVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                deviceInfoPayload[Constants.Payload.sdkVersion] = sdkVersion
            }
        }
        print(deviceInfoPayload)
        return deviceInfoPayload
    }

    internal static func appNameAndVersion(from infoDictionary: [String : String]) -> String
    {
         return "\(infoDictionary[Constants.Payload.appName] ?? "")/\(infoDictionary[Constants.Payload.appVersion] ?? "")"
    }
    

}
