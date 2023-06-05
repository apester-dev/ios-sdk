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
protocol EnvironmentViewControllerDelegate: AnyObject
{
    func navigateToNextPage(from currentViewController: EnvironmentViewController)
}
///
///
///
class EnvironmentViewController: UIViewController, Nibable, ViewModelable
{
    // MARK: - Properties
    var     viewModel : EnvironmentViewModel!
    weak var delegate : EnvironmentViewControllerDelegate?
    
    // MARK: - @IBOutlet
    @IBOutlet weak var environmentControl: UISegmentedControl!
    @IBOutlet weak var    gdprField: UITextField!
    @IBOutlet weak var   tokenField: UITextField!
    @IBOutlet weak var mediaIDField: UITextField!
    
    // MARK: - @IBAction
    @IBAction func environmentDidChange()
    {
        logger.debug()
        
        let e = environment(for: environmentControl.selectedSegmentIndex)
        viewModel.update(environment: e)
    }
    @IBAction func saveGDPR()
    {
        logger.debug()
        
        viewModel.update(gdpr: gdprField.text ?? String())
    }
    @IBAction func saveToken()
    {
        logger.debug()
        
        viewModel.update(token: tokenField.text ?? String())
    }
    @IBAction func saveMediaID()
    {
        logger.debug()
        
        viewModel.update(mediaID: mediaIDField.text ?? String())
    }
    @IBAction func clearInpiut()
    {
        logger.debug()
        
        [mediaIDField,tokenField,gdprField].forEach { $0?.text = nil }
        saveUIInformation()
    }
    @IBAction func activateFeed()
    {
        logger.debug()
        
        saveUIInformation()
        delegate?.navigateToNextPage(from: self)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Environment Selection"
        setupInitialUI(viewModel)
    }
    
    // MARK: - Helper methods
    private func setupInitialUI(_ viewModel: EnvironmentViewModel)
    {
        logger.debug()
        
        environmentControl.selectedSegmentIndex = index(for: viewModel.environment)
        mediaIDField.text = viewModel.mediaID
        tokenField.text   = viewModel.token
        gdprField.text    = viewModel.gdpr
        [mediaIDField,tokenField,gdprField].forEach { $0?.delegate = self }
    }
    private func saveUIInformation()
    {
        logger.debug()
        
        // Save ViewModel information
        environmentDidChange()
        saveGDPR()
        saveToken()
        saveMediaID()
        
        // trigger save of the ViewModel
        viewModel.save()
    }
    
    // MARK: - converter methods
    private func index(for environment: APEEnvironment) -> Int
    {
        switch environment {
        case .production: return 0
        case .stage     : return 1
        case .dev       : return 2
        case .local     : return 3
        }
    }
    private func environment(for index: Int) -> APEEnvironment
    {
        switch index {
        case 0: return .production
        case 1: return .stage
        case 3: return .local
        default: return .dev
        }
    }
}
extension EnvironmentViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.endEditing(true)
        return true
    }
}
