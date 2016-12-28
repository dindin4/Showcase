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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func fbButtonPressed(sender: UIButton!) {
        let facebookLogin  = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult?, facebookError: Error?) in
            if facebookError != nil {
                print("Facebook Login Failed. Error: \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                if let token = accessToken {
                    print(token)
                }
            }
        }
    }
}

