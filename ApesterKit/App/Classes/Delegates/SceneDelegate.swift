//
//  SceneDelegate.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import UIKit
///
///
///
@available(iOS 13.0, *)
class SceneDelegate : APEWindowSceneDelegateDispatcher {
    
    var window : UIWindow?
    
    override func obtainServices() -> [APESceneDelegate] {
        return [
            EnvironmentSceneDelegate()
        ]
    }
}
