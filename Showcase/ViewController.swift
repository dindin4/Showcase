//
//  ViewController.swift
//  Showcase
//
//  Created by Dinesh Vijaykumar on 28/12/2016.
//  Copyright © 2016 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passwordField:UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_UUID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbButtonPressed(sender: UIButton!) {
        let facebookLogin  = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult?, facebookError: Error?) in
            if facebookError != nil {
                print("Facebook Login Failed. Error: \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                if let token = accessToken {
                    print("Successfully logged in with facebook. Token - \(token)")
                    
                    let credential  = FIRFacebookAuthProvider.credential(withAccessToken: token)
                    FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in!")
                            UserDefaults.standard.set(user?.uid, forKey: KEY_UUID)
                            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func attemptLogin(sender:UIButton!) {
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            self.createUser(email: email, password: pwd)
                        case .errorCodeInvalidEmail:
                            self.showErrorAlert(title: "Could not login", msg: "Email not found")
                        case .errorCodeWrongPassword:
                            self.showErrorAlert(title: "Could not login", msg: "Password not correct")
                        case .errorCodeUserMismatch:
                            print("user mismatch - \(error)")
                        default:
                            self.showErrorAlert(title: "Could not login", msg: "Check your username and password")
                        }
                    }
                } else {
                    print("Logged in!")
                    UserDefaults.standard.set(user?.uid, forKey: KEY_UUID)
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            showErrorAlert(title: "Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    func createUser(email:String, password:String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user:FIRUser?, error:Error?) in
            if error != nil {
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .errorCodeUserMismatch:
                        print("user mismatch - \(error)")
                    case .errorCodeWeakPassword:
                        self.showErrorAlert(title: "Could not login", msg: "Password must be at least 6 characters long")
                    default:
                        self.showErrorAlert(title: "Could not create account", msg: "Problem creating account: \(error)")
                    }
                }
            } else {
                print("User Created - Logged in!")
                UserDefaults.standard.set(user?.uid, forKey: KEY_UUID)
                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
            }
        })
    }
    
    func showErrorAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

