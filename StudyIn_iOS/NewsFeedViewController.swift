//
//  ViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 1/27/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class FeedUser {
    var name : String
    var facebookID : String
    
    init() {
        self.name = ""
        self.facebookID = ""
    }
}

class NewsFeedViewController: PFQueryTableViewController {
    
    @IBOutlet var newsFeedTable: UITableView!
    let user = User.sharedInstance
    let parseDao : ParseDAO = ParseDAO()
    var feedObjects = Array<FeedObject>()
    
    // Variables for loading
    var loadingData = true
    var loadError = false
    var shouldLoadFromNetwork = true
    
    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 140.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "FeedItem"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 200
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery! {
        var query = PFQuery(className: "FeedItem")
        query.orderByDescending("createdAt")
        return query
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        
        if (indexPath.row < self.objects.count) {
            obj = self.objects[indexPath.row] as? PFObject
        }
        
        return obj
    }
    
    func queryDB(className: String, object : PFObject?) -> PFObject! {
        let objectID = object!.valueForKey("objectId") as! String
        
        var testQuery = PFQuery(className: className)
        testQuery.whereKey("objectId", equalTo: objectID)
        let objs = testQuery.findObjects()
        
        let newObj = objs[0] as! PFObject
        return newObj
    }
    
    func getUserInfo(object: PFObject) -> FeedUser {
        var myFeedUser : FeedUser = FeedUser()
        var myUser : PFObject = object["user"] as! PFObject
        var photo = ""
        var query = PFQuery(className: "StudyInUser")
        query.whereKey("objectId", equalTo: myUser.objectId)
        
        let objs = query.findObjects()
        if (objs.count != 0) {
            var tempUser = objs[0] as! PFObject
            myFeedUser.facebookID = tempUser["facebookID"] as! String
            myFeedUser.name = tempUser["name"] as! String
        }
        
        return myFeedUser
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        var status = object.valueForKey("statusUpdate") as? PFObject
        var checkin = object.valueForKey("checkIn") as? PFObject
        var checkout = object.valueForKey("checkOut") as? PFObject
        var feedUser = FeedUser()
        
        if (status != nil) {
            // Create a status update cell.
            let statusObj = queryDB("StatusUpdate", object: status)
            feedUser = getUserInfo(statusObj)
            var statusText = statusObj.valueForKey("statusText") as! String

            var courseText = ""
            if let course = statusObj.valueForKey("course") as? PFObject {
                let courseObj = queryDB("Course", object: course)
                courseText = courseObj.valueForKey("courseName") as! String
            }
            
            var profText = ""
            if let prof = statusObj.valueForKey("professor") as? PFObject {
                let courseObj = queryDB("Professor", object: prof)
                profText = prof.valueForKey("professorName") as! String
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
            cell.setUpCell(feedUser.name, statusText: statusText, course: courseText, professor: profText, photoURL: feedUser.facebookID);
            return cell;
        }
        else if (checkin != nil) {
            // Create a check-in cell.
            let checkInObj = queryDB("CheckIn", object: checkin)
            feedUser = getUserInfo(checkInObj)
            var locText = "location test"
            if let location = checkInObj.valueForKey("location") as? PFObject {
                let locObj = queryDB("Location", object: location)
                locText = locObj.valueForKey("name") as! String
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKIN, location: locText, photoURL: feedUser.facebookID)
            
            return cell;
        }
        else {
            let checkOutObj = queryDB("CheckOut", object: checkout)
            feedUser = getUserInfo(checkOutObj)
            // Create a check-out cell.
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKOUT, location: "", photoURL : feedUser.facebookID)
            
            return cell;
        }
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UnwindToHomeSegue" {
            self.tableView.reloadData()
        }
    }
}