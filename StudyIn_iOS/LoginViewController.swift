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
    let loginUser = User.sharedInstance
    var fbUser : FBGraphUser!
    var userInfoFetched = false
    
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
    }
    
    func saveUserToParse() {
        var testquery = PFQuery(className:"StudyInUser")
        testquery.whereKey("facebookID", equalTo: fbUser.objectID)
        var objects = testquery.findObjects()
        
        if (objects.count == 0) {
            // save object
            var userObject : PFObject = PFObject(className: "StudyInUser")
            userObject.setObject(fbUser.objectID, forKey: "facebookID")
            userObject.setObject(fbUser.name, forKey: "name")
            userObject.setObject("http://graph.facebook.com/\(fbUser.objectID)/picture?type=large", forKey: "facebookImageURL")
            userObject.saveInBackground()
            loginUser.parseUserObject = userObject
        }
        else {
            loginUser.parseUserObject = objects[0] as! PFObject
        }
    }
    
    func setActiveCheckIn() {
        var checkIns = PFQuery(className: "CheckIn")
        
        checkIns.whereKey("user", equalTo: PFObject(withoutDataWithClassName: "StudyInUser", objectId: loginUser.parseUserObject.objectId))
        
        var objects = checkIns.findObjects()
        
        if (objects.count != 0) {
            if let lastCheckIn: AnyObject = objects.last {
                if (lastCheckIn["checkOut"] != nil) {
                    loginUser.isCheckedIn = true
                    loginUser.parseActiveCheckIn = lastCheckIn as! PFObject
                }
                else {
                    loginUser.isCheckedIn = false
                }
            }
        }
        else {
            loginUser.isCheckedIn = false
        }
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        if (!userInfoFetched) {
            userInfoFetched = true
            
            let userName = user.name
            var userID = user.objectID
            var facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
            var userEmail = user.objectForKey("email") as! String
            
            self.loginUser.name = userName
            self.loginUser.email = userEmail
            self.loginUser.profilePicture = userID
            
            self.fbUser = user
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, UInt(0))) {
                self.saveUserToParse()
                self.setActiveCheckIn()
            
                dispatch_async(dispatch_get_main_queue()) {
                }
            };
            
            performSegueWithIdentifier("LoginToHomeSegue", sender: self)
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
