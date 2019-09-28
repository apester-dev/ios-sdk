//
//  UserAgent.swift
//  ApesterKit
//
//  Created by Hasan Sawaed Tabash on 9/28/19.
//  Copyright © 2019 Apester. All rights reserved.
//

import Foundation
import UIKit

class UserAgent {
    //eg. Darwin/16.3.0
    private static var darwinVersion: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    //eg. CFNetwork/808.3
    private static var CFNetworkVersion: String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary ?? [:]
        let version = dictionary[ "CFBundleShortVersionString"] as? String ?? ""
        return "CFNetwork/\(version)"
    }

    //eg. iOS/10_1
    private static var deviceVersion: String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    //eg. iPhone5,2
    private static var deviceName: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    static func customizedUA(with dictionary: [String : String]) -> String {
        return " WebViewApp \(BundleInfo.appNameAndVersion(from: dictionary)) \(deviceName) \(deviceVersion) \(CFNetworkVersion) \(darwinVersion)"
    }
}
