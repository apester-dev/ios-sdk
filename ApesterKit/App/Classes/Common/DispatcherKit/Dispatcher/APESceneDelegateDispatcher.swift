//
//  APESceneDelegateDispatcher.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
import UIKit
///
///
///
@available(iOS 13.0, *)
open class APESceneDelegateDispatcher : UIResponder {
    
    public override init() {
        super.init()
        _ = self.monitoredSceneServices
    }
    
    ///
    /// A public access to the services monitored by the dispatcher, allows a consumer of the framework to make a conviniance access variables
    ///
    public var monitoredSceneServices : [APESceneDelegate] {
        return sceneServices
    }
    
    ///
    /// Used to obtain an array of AFSAppDelegateService which are used as plugins,
    ///     to split handling UIApplicationDelegate implementation between several distinct control objects
    ///
    /// - Returns: services array containing the AFSAppDelegateService objects
    ///
    open func obtainServices() -> [APESceneDelegate] {
        
        return []
    }
    
    fileprivate lazy var sceneServices : [APESceneDelegate] = {
        return self.obtainServices()
    }()
    
    open override func responds(to aSelector: Selector!) -> Bool {
        
        // 01 Check if the selector is member of UIApplicationDelegate
        if let input = aSelector, input.isMember(of: UISceneDelegate.self) {
            
            // 02 Check if the selector is handled in one of the stored service objects
            for service in sceneServices where service.responds(to: input) {
                return true
            }
            
            // 03 Check if the selector is handled by our subclass
            if overridesSelector(input)
            {
                return super.responds(to: input)
            }
            return false
        } else {
            return super.responds(to: aSelector)
        }
    }
}
///
///
///
@available(iOS 13.0, *)
extension APESceneDelegateDispatcher : UISceneDelegate {
    
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        sceneServices.forEach { $0.scene?(scene, willConnectTo: session, options: connectionOptions) }
    }
    
    open func sceneDidDisconnect(_ scene: UIScene) {
        
        sceneServices.forEach { $0.sceneDidDisconnect?(scene) }
    }
    
    open func sceneDidBecomeActive(_ scene: UIScene) {
        
        sceneServices.forEach { $0.sceneDidBecomeActive?(scene) }
    }
    
    open func sceneWillResignActive(_ scene: UIScene) {
        
        sceneServices.forEach { $0.sceneWillResignActive?(scene) }
    }
    
    open func sceneWillEnterForeground(_ scene: UIScene) {
        
        sceneServices.forEach { $0.sceneWillEnterForeground?(scene) }
    }
    
    open func sceneDidEnterBackground(_ scene: UIScene) {
        
        sceneServices.forEach { $0.sceneDidEnterBackground?(scene) }
    }
    
    open func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        sceneServices.forEach { $0.scene?(scene, openURLContexts: URLContexts) }
    }
    
    // This is the NSUserActivity that will be used to restore state when the Scene reconnects.
    // It can be the same activity used for handoff or spotlight, or it can be a separate activity
    // with a different activity type and/or userInfo.
    // After this method is called, and before the activity is actually saved in the restoration file,
    // if the returned NSUserActivity has a delegate (NSUserActivityDelegate), the method
    // userActivityWillSave is called on the delegate. Additionally, if any UIResponders
    // have the activity set as their userActivity property, the UIResponder updateUserActivityState
    // method is called to update the activity. This is done synchronously and ensures the activity
    // has all info filled in before it is saved.
    open func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        
        for service in sceneServices {
            guard let result = service.stateRestorationActivity?(for: scene) else { continue }
            return result
        }
        return nil
    }
    
    open func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        
        sceneServices.forEach { $0.scene?(scene, willContinueUserActivityWithType: userActivityType) }
    }
    open func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        sceneServices.forEach { $0.scene?(scene, continue: userActivity) }
    }
    open func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        
        sceneServices.forEach { $0.scene?(scene, didFailToContinueUserActivityWithType: userActivityType, error: error) }
    }
    open func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        
        sceneServices.forEach { $0.scene?(scene, didUpdate: userActivity) }
    }
}
