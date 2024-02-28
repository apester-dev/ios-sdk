//
//  AppDelegate.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import UIKit
///
///
///
@main
open class AppDelegate : APEApplicationDelegateDispatcher
{
    open var window : UIWindow?
    
    static var shared : AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    open override func obtainServices() -> [APEApplicationDelegateService] {
        return [
            LoggerService(),
            SDKLoggerService(),
            FeedMonitorService()
        ]
    }
}
extension AppDelegate
{
    func retrieveService<S>(of serviceType: S.Type) -> S where S : APEApplicationDelegateService {
        
        guard let result = monitoredApplicationServices.first(where: {
            type(of: $0) == S.self
        }) as? S else {
            
            fatalError("""
                A predefined service is missing,  \
                something is wrong in the AppDelegate file,  \
                check the \(String(describing: serviceType)) definition
            """)
        }
        return result
    }
    
    var      loggerService: LoggerService      { retrieveService(of: LoggerService.self) }
    var fileWatcherService: FeedMonitorService { retrieveService(of: FeedMonitorService.self) }
}
///
/// MARK: - Application Lifecycle
///
extension AppDelegate
{
    open override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        let result = super.application(application, willFinishLaunchingWithOptions: launchOptions)
        return result
    }
    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        return result
    }
}
///
/// MARK: - UISceneSession Lifecycle
///
extension AppDelegate
{
    @available(iOS 13.0, *)
    override open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    override open func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
