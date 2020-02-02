//
//  AppDelegate.swift
//  Apester
//
//  Created by Hasan Sa on 28/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import ApesterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    APEStripViewService.shared.preloadStripViews(with: StripConfigurationsFactory.configurations)
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

@objcMembers class StripConfigurationsFactory: NSObject {
    private static let style: APEStripStyle = {
        APEStripStyle(shape: .roundSquare,
                      size: .medium,
                      padding: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 0, right: 0),
                      shadow: false,
                      textColor: nil,
                      background: .white,
                      header: APEStripHeader(text: "Weitere Beiträge", size: 25.0, family: "Knockout", weight:400, color: .black))
    }()

    static let configurations: [APEStripConfiguration] = {
        let tokens = ["5e03500a2fd560e0220ff327", "5ad092c7e16efe4e5c4fb821", "58ce70315eeaf50e00de3da7", "5aa15c4f85b36c0001b1023c"]
        return makeStripConfigurations(with: tokens)
    }()

    /// transform all given channel toekns to [APEStripConfiguration]
    /// - Parameter channleTokens: the channelTokens to transform
    static func makeStripConfigurations(with channleTokens: [String]) -> [APEStripConfiguration] {
        channleTokens.compactMap {
            try? APEStripConfiguration(channelToken: $0, style: style, bundle: Bundle.main)
        }
    }
}


