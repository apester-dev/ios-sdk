//
//  loginViewController.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/28/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        loginView.layer.shadowOpacity = 0.5
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowOffset = CGSize(width: 3, height: 3)
        loginView.layer.shadowRadius = 5
        loginView.layer.masksToBounds = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            loginAction()
        }
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextFieldFrames(isError: false)
    }
    
    @IBAction func LoginButtonAction(_ sender: Any) {
        loginAction()
    }
    func updateTextFieldFrames(isError:Bool){
        let color = isError ? UIColor.red : UIColor.clear // Red color on error, clear otherwise
        userNameTextField.layer.borderColor = color.cgColor
        userNameTextField.layer.borderWidth = isError ? 1.0 : 0.0
        passwordTextField.layer.borderColor = color.cgColor
        passwordTextField.layer.borderWidth = isError ? 1.0 : 0.0
        errorLabel.isHidden = !isError
        loginView.layer.shadowColor = isError ? UIColor.red.cgColor:  UIColor.black.cgColor
        
    }
    func loginAction(){
        guard let userName = userNameTextField.text, !userName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else { return }
        Auth.auth().signIn(withEmail: userName, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                self?.updateTextFieldFrames(isError: true)
                // uncomment and run to add new users
                //                if error.code == AuthErrorCode.userNotFound.rawValue {
                //                    self?.registerNewUser(userName: userName, password: password)
                //                } else {
                //                    print("login error")
                //                }
                return
            }
            //navigate to next screen
            self?.navigateToMain()
        }
    }
    func navigateToMain(){
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let navigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController
        //        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as? mainViewController {
        //            if navigationController == nil {
        //                       print("NavigationController is nil")
        //                   } else {
        //                       navigationController?.pushViewController(nextViewController, animated: true)
        //                   }
        //        }
        AppTrackingHelper.requestTrackingPermission(permissionSuccess: {
            (UIApplication.shared.delegate as! AppDelegate).logInUser()
        }, viewController: self)
        //        (UIApplication.shared.delegate as! AppDelegate).logInUser()
    }
    
    func registerNewUser(userName: String, password: String) {
        Auth.auth().createUser(withEmail: userName, password: password) { authResult, error in
            if let error = error {
                print("Registration error: \(error.localizedDescription)")
                // Handle registration error
                return
            }
            // New user created successfully
            self.navigateToMain()
            
            // Navigate to next screen or update UI
        }
    }
    
}
