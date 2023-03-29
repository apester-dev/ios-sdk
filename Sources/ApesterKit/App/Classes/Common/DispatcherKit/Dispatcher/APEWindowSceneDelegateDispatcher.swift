//
//  APEWindowSceneDelegateDispatcher.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
import UIKit
///
///
///
@available(iOS 13.0, *)
open class APEWindowSceneDelegateDispatcher : APESceneDelegateDispatcher {
    
    public override init() {
        super.init()
        _ = self.monitoredWindowSceneServices
    }
    
    ///
    /// A public access to the services monitored by the dispatcher, allows a consumer of the framework to make a conviniance access variables
    ///
    public var monitoredWindowSceneServices : [APEWindowSceneDelegateService] {
        return windowSceneServices
    }
    
    ///
    /// Used to obtain an array of AFSAppDelegateService which are used as plugins,
    ///     to split handling UIApplicationDelegate implementation between several distinct control objects
    ///
    /// - Returns: services array containing the AFSAppDelegateService objects
    ///
    open func obtainWindowSceneServices() -> [APEWindowSceneDelegateService] {
        
        return []
    }
    
    fileprivate lazy var windowSceneServices : [APEWindowSceneDelegateService] = {
        return self.obtainWindowSceneServices()
    }()
    
    open override func responds(to aSelector: Selector!) -> Bool {
        
        // 01 Check if the selector is member of UIApplicationDelegate
        if let input = aSelector, input.isMember(of: UIWindowSceneDelegate.self) {
            
            // 02 Check if the selector is handled in one of the stored service objects
            for service in windowSceneServices where service.responds(to: input) {
                return true
            }
            
            // 03 Check if the selector is handled by our subclass
            if overridesSelector(input)
            {
                return super.responds(to: input)
            }
            
            // 04 Spesificly handle the window property, this is the only oprperty in the protocol
            if  sel_isEqual(input, #selector(getter: UIWindowSceneDelegate.window)) ||
                sel_isEqual(input, #selector(setter: UIWindowSceneDelegate.window))
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
extension APEWindowSceneDelegateDispatcher : UIWindowSceneDelegate {
    
    open func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        
        windowSceneServices.forEach { $0.windowScene?(windowScene, didUpdate: previousCoordinateSpace, interfaceOrientation: previousInterfaceOrientation, traitCollection: previousTraitCollection) }
    }
    
    // Called when the user activates your application by selecting a shortcut on the home screen,
    // and the window scene is already connected.
    open func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        windowSceneServices.forEach { $0.windowScene?(windowScene, performActionFor: shortcutItem, completionHandler: completionHandler) }
    }
    
    // // Called after the user indicates they want to accept a CloudKit sharing invitation in your application
    // // and the window scene is already connected.
    // // You should use the CKShareMetadata object's shareURL and containerIdentifier to schedule a CKAcceptSharesOperation, then start using
    // // the resulting CKShare and its associated record(s), which will appear in the CKContainer's shared database in a zone matching that of the record's owner.
    // open func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
    //
    //     windowSceneServices.forEach { $0.windowScene?(windowScene, userDidAcceptCloudKitShareWith: cloudKitShareMetadata) }
    // }
}
