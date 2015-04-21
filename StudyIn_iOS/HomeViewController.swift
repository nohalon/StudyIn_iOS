//
//  ViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 1/27/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController, UITableViewDelegate {

    @IBOutlet var newsFeedTable: UITableView!
    let user = User.sharedInstance
    let parseDao : ParseDAO = ParseDAO()
    var feedObjects = Array<FeedObject>()
    
    // Variables for loading
    var loadingData = true
    var loadError = false
    var shouldLoadFromNetwork = true
    
    func reloadFeedTable() {
        
        /*for (index, element) in enumerate(sortedAlphabet) {
            alphabet[index] = element
        }*/
        
        //tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        // pull to refresh
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("reloadFeedTable"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        newsFeedTable.estimatedRowHeight = 140.0;
        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        
        newsFeedTable.dataSource = self;
        newsFeedTable.delegate = self;
    }
    
    func loadDataFromParse() {
        
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
    
    func updateView() {
        // get all new info from parse
        self.tableView.reloadData()
    }
    
    func reloadFeedObjects() {
        var newsFeedObjectsArray = Array<FeedObject>()
        
        let checkIns = parseDao.getAllCheckIns()
        let checkOuts = parseDao.getAllCheckOuts()
        let statusUpdates = parseDao.getAllPosts()
        
        for checkIn in checkIns {
            var locationObj = checkIn.valueForKey("location") as! PFObject!
            var location = locationObj.valueForKey("name") as! String!
            
            var feedObject = UserCheckInOut(type: .CHECKIN, timeStamp: checkIn.createdAt, objectId: checkIn.objectId, silentPost: false, location: location)
            
            newsFeedObjectsArray.append(feedObject)
        }
        for checkOut in checkOuts {
            var checkIn = checkOut.valueForKey("checkIn") as! PFObject!
            var locationObj = checkIn.valueForKey("location") as! PFObject!
            var location = locationObj.valueForKey("name") as! String!
            
            var feedObject = UserCheckInOut(type: .CHECKOUT, timeStamp: checkOut.createdAt, objectId: checkOut.objectId, silentPost: false, location: location)
            
            newsFeedObjectsArray.append(feedObject)
        }
        for statusUpdate in statusUpdates {
            var status = statusUpdate.valueForKey("statusText") as! String!
            
            
            var course = statusUpdate.valueForKey("course") as! PFObject!
            
            //var courseName = course["courseName"] as! String!
            var courseName = "hey"
            
            var prof = statusUpdate.valueForKey("professor") as! PFObject!
            var profName = "you"
            //var profName = prof["professorName"] as! String!
            
            var feedObject = UserPost(type: FeedObjectType.STATUSUPDATE, objectId: statusUpdate.objectId, timeStamp: statusUpdate.createdAt, statusText: status, classText: courseName, professorText: profName)
            
            newsFeedObjectsArray.append(feedObject)
        }
        
        func feedObjectSort(feedObject1: FeedObject, feedObject2: FeedObject) -> Bool {
            return feedObject1.timestamp.compare(feedObject2.timestamp) == NSComparisonResult.OrderedDescending
        }
        
        var sortedArray = sorted(newsFeedObjectsArray, feedObjectSort)
        
        self.feedObjects = sortedArray
    }
    
    func loadData() {
        loadError = false
        loadingData = false
        
        if shouldLoadFromNetwork {
            loadError = false
            loadingData = true
            self.tableView.reloadData()
            
            // TODO: This will need to change if we add a way to refresh this page, which we probably will.
            // Instead, we could use the NSURLConnection asynchrounous call. This is because users could
            // refresh the page faster than this call could load it, resulting in multiple threads doing
            // the same operation and messing up the table view.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.reloadFeedObjects()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.loadingData = false
                    self.tableView.reloadData()
                })
            })
            
        } else {
            // fake feed objects
            self.tableView.reloadData()
        }
    }
}

extension HomeViewController : UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedObj = feedObjects[indexPath.row]
        
        switch feedObj.objectType {
            
        case .STATUSUPDATE:
            let statusObj = feedObj as! UserPost
            let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
            cell.setUpCell(statusObj.statusTxt, course: statusObj.classTxt, professor: statusObj.professorTxt);
            
            return cell;
        case .CHECKIN:
            let checkInObj = feedObj as! UserCheckInOut
            
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(FeedObjectType.CHECKIN, location: checkInObj.location)
            
            return cell;
        case .CHECKOUT:
            let checkOutObj = feedObj as! UserCheckInOut

            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(FeedObjectType.CHECKOUT, location: checkOutObj.location)
            
            return cell;
        }
        
        /*if (indexPath.row == 0 || indexPath.row == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
            
            cell.setUpCell();
            
            return cell;
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInCell") as! UserCheckInOutCell
            
            cell.setUpCell()
            
            return cell;
        }*/
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedObjects.count
    }
}

