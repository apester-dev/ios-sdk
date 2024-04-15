//
//  AppTrackingHelper.swift
//  Apester
//
//  Created by Michael Krotorio on 3/10/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import AppTrackingTransparency
import UIKit
class AppTrackingHelper {
    static func requestTrackingPermission(permissionCallback: @escaping () -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async { // Ensure UI updates are on the main thread.
                   permissionCallback()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }


   
}

