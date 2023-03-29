//
//  WaitingScreenCoordinator.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import Foundation
import UIKit
///
///
///
protocol WaitingScreenCoordinatorDelegate: AnyObject
{
    func navigateBack(from coordinator: WaitingScreenCoordinator)
}
///
///
///
final class WaitingScreenCoordinator : Coordinator
{
    var children : [Coordinator]
    
    // we use this delegate to keep a reference to the Navigation controller without upping the referance count
    unowned let navigationController: UINavigationController
    
    // We use this delegate to keep a reference to the parent coordinator
    weak var delegate: WaitingScreenCoordinatorDelegate?
    
    // Tracks the current Apester environment
    weak var environmentData : EnvironmentModel!

    init(controller: UINavigationController) {
        self.navigationController = controller
        self.children             = [Coordinator]()
    }
    
    func start()
    {
        logger.debug()
        let viewModel      = WaitingScreenViewModel(environmentData)
        let viewController = WaitingScreenViewController.instantiate(with: viewModel)
        viewController.delegate = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
extension WaitingScreenCoordinator : WaitingScreenViewControllerDelegate
{
    func navigateBack()
    {
        logger.debug()
        delegate?.navigateBack(from: self)
    }
    func navigateToNextPage(from currentViewController: WaitingScreenViewController)
    {
        logger.debug()
        
        let coordinator = FeedCoordinator(controller: navigationController)
        coordinator.delegate = self
        coordinator.environmentData = currentViewController.viewModel.model
        children.append(coordinator)
        coordinator.start()
    }
}
extension WaitingScreenCoordinator : FeedCoordinatorDelegate
{
    func navigateBack(from coordinator: FeedCoordinator)
    {
        logger.debug()

        navigationController.popViewController(animated: true)
        children.removeLast()
    }
}
