//
//  ProfileViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePictureView: FBProfilePictureView!
    @IBOutlet weak var userNameLbl: UILabel!
    let user = User.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadUserDetails()
    }
    
    func loadUserDetails() {
        profilePictureView.profileID = user.profilePicture
        userNameLbl.text = user.name
        
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
        self.profilePictureView.clipsToBounds = true;
        
        self.profilePictureView.layer.borderWidth = 2.0;
        var myColor : UIColor = uicolorFromHex(0x62CDFF)
        self.profilePictureView.layer.borderColor = myColor.CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSettingsActionSheet(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            FBSession.activeSession().closeAndClearTokenInformation()
            self.performSegueWithIdentifier("unwindFromProfile", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

class ProfileTableViewController: PFQueryTableViewController {
    
    @IBOutlet var feedTable: UITableView!
    
    let user = User.sharedInstance
    let parseDao : ParseDAO = ParseDAO()
    
    override init(style: UITableViewStyle, className: String!) {
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
    override func queryForTable() -> PFQuery {
        var query = PFQuery(className: "FeedItem")
        query.whereKey("user", equalTo: user.parseUserObject)
        
        query.includeKey("user")
        query.includeKey("checkOut")
        query.includeKey("checkOut.location")
        query.includeKey("checkIn")
        query.includeKey("checkIn.location")
        query.includeKey("statusUpdate")
        query.includeKey("statusUpdate.course")
        query.includeKey("statusUpdate.professor")
        query.orderByDescending("createdAt")
        
        return query
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        
        if (indexPath.row < self.objects!.count) {
            obj = self.objects![indexPath.row] as? PFObject
        }
        
        return obj
    }
    
    func queryDB(className: String, object : PFObject?) -> PFObject! {
        let objectID = object!.valueForKey("objectId") as! String
        
        var testQuery = PFQuery(className: className)
        testQuery.whereKey("objectId", equalTo: objectID)
        let objs = testQuery.findObjects()
        
        let newObj = objs![0] as! PFObject
        return newObj
    }
    
    func getUserInfo(myUser: PFObject) -> FeedUser {
        var myFeedUser : FeedUser = FeedUser()
        var photo = ""
        
        myFeedUser.facebookID = myUser["facebookID"] as! String
        myFeedUser.name = myUser["name"] as! String
        
        return myFeedUser
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        var status = object.valueForKey("statusUpdate") as? PFObject
        var checkin = object.valueForKey("checkIn") as? PFObject
        var checkout = object.valueForKey("checkOut") as? PFObject
        var feedUser = FeedUser()
        
        if (status != nil) {
            // Create a status update cell.
            let statusObj = status!
            feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
            var statusText = statusObj.valueForKey("statusText") as! String
            
            var courseText = ""
            if let course = statusObj.valueForKey("course") as? PFObject {
                courseText = course.valueForKey("courseName") as! String
            }
            
            var profText = ""
            if let prof = statusObj.valueForKey("professor") as? PFObject {
                profText = prof.valueForKey("professorName") as! String
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
            cell.setUpCell(feedUser.name, statusText: statusText, course: courseText, professor: profText, photoURL: feedUser.facebookID, time: statusObj.createdAt);
            return cell;
        }
        else if (checkin != nil) {
            // Create a check-in cell.
            let checkInObj = checkin!
            feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
            var locText = "location test"
            if let location = checkInObj.valueForKey("location") as? PFObject {
                locText = location.valueForKey("name") as! String
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKIN, location: locText, photoURL: feedUser.facebookID, time: checkInObj.createdAt)
            
            return cell;
        }
        else {
            
            let checkOutObj = checkout!
            let user1 = object["user"] as? PFObject
            feedUser = getUserInfo(user1!)
            // Create a check-out cell.
            let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
            cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKOUT, location: "", photoURL : feedUser.facebookID, time: checkOutObj.createdAt)
            
            return cell;
        }
    }
    
}


