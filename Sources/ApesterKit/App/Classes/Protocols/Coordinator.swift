//
//  Coordinator.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import UIKit
///
///
///
protocol Coordinator
{
    var children: [Coordinator] { get set }
    
    // All coordinators will be initilised with a navigation controller
    init(controller: UINavigationController)
    
    func start()
}
