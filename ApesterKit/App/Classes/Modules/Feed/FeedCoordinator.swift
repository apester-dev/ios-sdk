//
//  MainCoordinator.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import UIKit
import Foundation
import ApesterKit
///
///
///
protocol FeedCoordinatorDelegate: AnyObject
{
    func navigateBack(from coordinator: FeedCoordinator)
}
///
///
///
final class FeedCoordinator : Coordinator
{
    var children : [Coordinator]
    
    // we use this delegate to keep a reference to the Navigation controller without upping the referance count
    unowned let navigationController: UINavigationController
    
    // We use this delegate to keep a reference to the parent coordinator
    weak var delegate: FeedCoordinatorDelegate?
    
    // Tracks the current Apester environment
    weak var environmentData : EnvironmentModel?
    
    required init(controller : UINavigationController)
    {
        self.children = [Coordinator]()
        self.navigationController = controller
    }
    
    func start()
    {
        logger.debug()
        
        if let data = environmentData
        {
            logger.debug("Environment Data:\n\(data.debugDescription)")
            
            let viewModel  = FeedViewModel(environment: data)
            let controller = FeedViewController.instantiate(with: viewModel)
            controller.delegate = self
            viewModel.delegate  = controller
            navigationController.pushViewController(controller, animated: true)
        }
    }
}
extension FeedCoordinator: FeedViewControllerDelegate
{
    // Navigate to first page
    func navigateBack()
    {
        delegate?.navigateBack(from: self)
    }
}
