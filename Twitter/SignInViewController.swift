//
//  SignInViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/18/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBAction func onSignIn(sender: AnyObject) {
        TwitterClient.sharedInstance.logInWithCompletion() {
            (user: User?, error: NSError?) in
            if user != nil {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.setUpHamburger()
            } else {
                print("Error logging in")
            }
            
        }
    }
}
