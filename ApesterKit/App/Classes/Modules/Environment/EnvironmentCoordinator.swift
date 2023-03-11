//
//  EnvironmentCoordinator.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import Foundation
import UIKit
///
///
///
final class EnvironmentCoordinator : Coordinator
{
    var children             : [Coordinator]
    var navigationController :  UINavigationController

    init(controller: UINavigationController) {
        self.navigationController = controller
        self.children             = [Coordinator]()
    }
    
    func start()
    {
        logger.debug()
        
        let viewModel      = EnvironmentViewModel()
        let viewController = EnvironmentViewController.instantiate(with: viewModel)
        viewController.delegate = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
extension EnvironmentCoordinator : EnvironmentViewControllerDelegate
{
    func navigateToNextPage(from currentViewController: EnvironmentViewController)
    {
        logger.debug()
        
         let coordinator = WaitingScreenCoordinator(controller: navigationController)
         coordinator.delegate = self
         coordinator.environmentData = currentViewController.viewModel.model
         children.append(coordinator)
         coordinator.start()
    }
}
extension EnvironmentCoordinator : WaitingScreenCoordinatorDelegate
{
    func navigateBack(from coordinator: WaitingScreenCoordinator)
    {
        logger.debug()
        
        navigationController.popToRootViewController(animated: true)
        children.removeLast()
    }
}
