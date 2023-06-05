//
//  EnvironmentViewController.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import UIKit
import ApesterKit
///
///
///
protocol WaitingScreenViewControllerDelegate: AnyObject
{
    func navigateBack()
    func navigateToNextPage(from currentViewController: WaitingScreenViewController)
}
///
///
///
class WaitingScreenViewController : UIViewController , Nibable, ViewModelable
{
    // MARK: - Properties
    var     viewModel : WaitingScreenViewModel!
    weak var delegate : WaitingScreenViewControllerDelegate?
    
    var waitingScreenTimer: Timer!
    
    // MARK: - @IBOutlet
    @IBOutlet weak var      statusLabel : UILabel!
    @IBOutlet weak var activationButton : UIButton! {
        didSet {
            activationButton.isEnabled = false
        }
    }
    
    // MARK: - @IBAction
    @IBAction func activateFeed()
    {
        logger.debug()
        delegate?.navigateToNextPage(from: self)
    }
    
    // MARK: - Selector activations
    @objc func navigateBackToFirstpage()
    {
        delegate?.navigateBack()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Wait for unit activation"
        
        setupApesterViews()
        setupNavigationViews()
        
        waitingScreenTimer = Timer.init(timeInterval: TimeInterval(1.0), repeats: true) { timer in
            
            guard self.isApesterUnitLoaded() else { return }
            self.updateUI()
        }
        RunLoop.main.add(waitingScreenTimer, forMode: RunLoop.Mode.default)
    }
    
    deinit {
        waitingScreenTimer.invalidate()
        waitingScreenTimer = nil
        APEViewService.shared.unloadUnitViews(with: viewModel.model.unitIdentifiers)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // let service = APEViewService.shared
        // viewModel.environmentData.unitIdentifiers.forEach { identifier in
        //     service.unitView(for: identifier)?.resume()
        // }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        // let service = APEViewService.shared
        // viewModel.environmentData.unitIdentifiers.forEach { identifier in
        //     service.unitView(for: identifier)?.stop()
        // }
    }
    
    // MARK: - Helper methods
    func setupApesterViews()
    {
        
        let service = APEViewService.shared
        
        viewModel.model.unitConfigurations.forEach { configuration in
            
            if service.unitView(for: configuration.unitParams.id) == nil {
                
                // not preload!
                service.preloadUnitViews(with: [configuration])
            }
            service.unitView(for: configuration.unitParams.id)?.delegate = self
        }
    }
    func setupNavigationViews()
    {
         let backSelector = #selector(navigateBackToFirstpage)
         // Use custom back button to pass through coordinator.
         let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: backSelector)
         navigationItem.leftBarButtonItem = backButton
    }
    
    func isApesterUnitLoaded() -> Bool
    {
        let configurations = viewModel.model.unitConfigurations
        let service = APEViewService.shared

        var currentCount = Int(0)
        for configuration in configurations where service.unitView(for: configuration.unitParams.id).demo_isExist
        {
            currentCount += 1
        }
        
        return currentCount == configurations.count
    }
    func updateUI()
    {
        statusLabel.text = "Apester units ready"
        activationButton.isEnabled = true
        waitingScreenTimer.invalidate()
    }
}
///
///
///
extension WaitingScreenViewController : APEUnitViewDelegate
{
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
        
        DispatchQueue.main.async {
            
            APEViewService.shared.unloadUnitViews(with: [unitId])
        }
    }
    
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
    }
    
    func unitView(_ unitView: APEUnitView, didCompleteAdsForUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
    }
    
    func unitView(_ unitView: APEUnitView, didUpdateHeight height: CGFloat)
    {
        logger.debug("unitId: \(unitView.configuration.unitParams.id), ### height: \(height)")
    }
}
