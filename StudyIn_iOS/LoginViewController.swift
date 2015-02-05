//
//  LoginViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/4/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var fbLoginView: FBLoginView!
    var loginUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        performSegueWithIdentifier("LoginToHomeSegue", sender: self)
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        //println("User: \(user)")
        //println("User ID: \(user.objectID)")
        //println("User Name: \(user.name)")
        //println("User Email: \(userEmail)")
        //var facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"

        let userName = user.name
        var userID = user.objectID
        var userEmail = user.objectForKey("email") as String
        
        
        // set the user object
        if let mainTabBarController = self.tabBarController as? MainTabBarController {
             mainTabBarController.user = User(name: userName, email: userEmail, profilePicture: userID)
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    @IBAction func unwindToLoginView(unwindSegue: UIStoryboardSegue) {
        if let profileViewController = unwindSegue.sourceViewController as? ProfileViewController {
            println("Coming from profile")
        }
    }
}
