//
//  ViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 1/27/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class HomeViewController: PFQueryTableViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var newsFeedTable: UITableView!
    let user = User.sharedInstance

    // Initialise the PFQueryTable tableview
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "NewsFeed"
        self.textKey = "nameEnglish"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var testObject : PFObject = PFObject(className: "TestObject")
        //testObject["foo"] = "bar"
        //testObject.save()
        
        newsFeedTable.estimatedRowHeight = 140.0;
        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        
        newsFeedTable.dataSource = self;
        newsFeedTable.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "StatudCheckInSegue") {
            let destination = segue.destinationViewController as! UINavigationController
            let statusCheckInController = destination.viewControllers[0] as! StatusCheckInViewController
            statusCheckInController.delegate = self
        }
    }
    
    @IBAction func segueToCheckInOut(sender: UIButton) {
        self.performSegueWithIdentifier("StatusCheckInSegue", sender: self)
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {

    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let feedObject = list[indexPath.row]
        // if its a check in, do...
        // its its a post, do...
        
        if (indexPath.row == 0 || indexPath.row == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
            
            cell.setUpCell();
            
            return cell;
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell") as! UserCheckInOutCell
            
            cell.setUpCell()
            
            return cell;
        }
    
    }
    
    func updateView() {
        // get all new info from parse
        self.tableView.reloadData()
    }
}

