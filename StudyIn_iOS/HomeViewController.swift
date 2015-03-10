//
//  ViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 1/27/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {

    let user = User.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var testObject : PFObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.save()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segueToCheckInOut(sender: UIButton) {
        self.performSegueWithIdentifier("StatusCheckInSegue", sender: self)
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        
    }
}

