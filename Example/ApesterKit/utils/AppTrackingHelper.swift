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
    static func requestTrackingPermission(permissionSuccess: @escaping () -> Void, viewController: UIViewController) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async { // Ensure UI updates are on the main thread.
                    switch status {
                    case .authorized:
                        print("Tracking authorized")
                        permissionSuccess()
                    case .denied, .restricted, .notDetermined:
                        // Provide an alternative experience or show a message to the user.
                        showCustomPermissionDeniedAlert(from: viewController)
                    @unknown default:
                        print("Unknown tracking authorization status")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    static func showCustomPermissionDeniedAlert(from viewController: UIViewController) {
       let alert = UIAlertController(title: "Tracking Permission Required", message: "This permission enhances your app experience by [...]. You can enable tracking in Settings.", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
           if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           }
       }))
       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
   }
   
}

