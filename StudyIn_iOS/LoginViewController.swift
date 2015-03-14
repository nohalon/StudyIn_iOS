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
        saveUserToParse()
        performSegueWithIdentifier("LoginToHomeSegue", sender: self)
    }
    
    func saveUserToParse() {
//        var testObject = PFObject(className:"TestObject")
//        testObject["foo"] = "testing this"
//        testObject.saveInBackground()
        
        
        // save user to parse
        /*var userObject : PFObject = PFObject(className: "StudyInUser")
        userObject.setObject(userID, forKey: "facebookID")
        userObject.setObject(userName, forKey: "name")
        userObject.setObject(facebookProfileUrl, forKey: "facebookImageURL")
        
        var userObj = PFObject(className:"StudyInUser")
        userObj["facebookID"] = userID
        userObj["name"] = userName
        userObj["facebookImageURL"] = facebookProfileUrl
        userObj.saveInBackgroundWithBlock {
        (success: Bool, error: NSError!) -> Void in
        if (success) {
        // The object has been saved.
        } else {
        // There was a problem, check error.description
        }
        }
        
        var query = PFQuery(className: "GameScore")
        query.getObjectInBackgroundWithId(gameScore.objectId) {
        (scoreAgain: PFObject!, error: NSError!) -> Void in
        if !error {
        NSLog("%@", scoreAgain.objectForKey("playerName") as NSString)
        } else {
        NSLog("%@", error)
        }
        }*/
        
        var testquery = PFQuery(className:"StudyInUser")
        //query.whereKey("facebookID", equalTo: fbUser.objectID)
        println("print this")
        testquery.findObjectsInBackgroundWithBlock {(objects:[AnyObject]!, error: NSError!) in
            if(error == nil){
                println("here2")
                // The find succeeded.
                println("Successfully retrieved \(objects) scores.")
                // Do something with the found objects
                /*if let objects = objects as? [PFObject] {
                    for object in objects {
                        println(object.objectId)
                    }
                }*/
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {

        let userName = user.name
        var userID = user.objectID
        var facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
        var userEmail = user.objectForKey("email") as! String
        
        self.loginUser.name = userName
        self.loginUser.email = userEmail
        self.loginUser.profilePicture = userID
        
        self.fbUser = user
        
        // check if the id exists
        // if it does, get it
        // if it doesn't, save a new one
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
