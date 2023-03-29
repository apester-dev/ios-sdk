//
//  EnvironmentSceneDelegate.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import UIKit
///
///
///
@available(iOS 13.0, *)
final class EnvironmentSceneDelegate : NSObject
{
    var window      : UIWindow?
    var coordinator : EnvironmentCoordinator?
}
// MARK: - APEApplicationDelegateService
@available(iOS 13.0, *)
extension EnvironmentSceneDelegate : APESceneDelegate
{
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        let navigationController = UINavigationController()
        window?.rootViewController = navigationController

        // Initialise the first coordinator with the main navigation controller
        coordinator = EnvironmentCoordinator(controller: navigationController)
        
        // The start method will actually display the main view
        coordinator?.start()
        
        // Make the scene's window the one the application focuses on
        window?.makeKeyAndVisible()
    }
}
