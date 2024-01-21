//
//  AppDelegate.swift
//  ApesterTestApp
//
//  Created by Michael Krotorio on 11/26/23.
//

import UIKit
import ApesterKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        APELoggerService.shared.enabled = true
        APELoggerService.shared.formatter = APELogger.Formatters.Concatenating([
            APELogger.Formatters.standard,
            APELogger.Formatters.FunctionFormatter()
        ])
        APELoggerService.shared.writer = APELogger.Writers.Redirecting(writers: [
            APELogger.Writers.standard,
            DemoLogWriter()
        ])

        // initiate UnitConfigurationsFactory environment
        UnitConfigurationsFactory.environment = .production
        
        let configurations = UnitConfigurationsFactory.configurations(hideApesterAds: false, gdprString: UnitConfigurationsFactory.gdprString, baseUrl: UnitConfigurationsFactory.baseUrl)
        
        // preloadUnitViews
        APEViewService.shared.preloadUnitViews(with: configurations)
        return true
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

