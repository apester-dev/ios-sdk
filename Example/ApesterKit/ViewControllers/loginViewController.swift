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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func LoginButtonAction(_ sender: Any) {
        guard let userName = userNameTextField.text, !userName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else { return }
        Auth.auth().signIn(withEmail: userName, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    self?.registerNewUser(userName: userName, password: password)
                } else {
                    print("login error")
                }
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
        (UIApplication.shared.delegate as! AppDelegate).logInUser()
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
