//
//  GroupFeedTableViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 5/15/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class GroupFeedUserCell : PFTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbPhoto: FBProfilePictureView!
    
    func addUserPhoto(fbID : String) {
        fbPhoto.profileID = fbID
        
        self.fbPhoto.layer.cornerRadius = self.fbPhoto.frame.size.width / 2
        self.fbPhoto.clipsToBounds = true
        
        self.fbPhoto.layer.borderWidth = 1.0
        
        var myColor : UIColor = Utils.uicolorFromHex(0x62CDFF)
        self.fbPhoto.layer.borderColor = myColor.CGColor
    }
}

class SegmentationCell : PFTableViewCell {
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!

}

class GroupFeedTableViewController  : PFQueryTableViewController {
    let GROUP_IMAGE_INDEX = 0
    let GROUP_DESC_INDEX = 1
    let SEGMENT_CONTROL_INDEX = 2
    
    let DETAILS_SECTION = 0
    let DYNAMIC_SECTION = 1
    
    let FEED_INDEX = 0
    let MEMBERS_INDEX = 1
    let STATS_INDEX = 2
    
    var segmentedControl : UISegmentedControl?
    let user = User.sharedInstance
    var group : PFObject?
    var members : [PFObject]?
    var index = 0
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Group"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        var usersRelation = group!.relationForKey("users") as PFRelation
        var query = usersRelation.query()
        
        /*if let segmentedControl = self.segmentedControl {
            switch segmentedControl.selectedSegmentIndex {
            case FEED_INDEX:
                if members != nil {
                    var feedItemQuery = PFQuery(className: "FeedItem")

                    feedItemQuery.whereKey("user", containedIn: self.members)
                    feedItemQuery.orderByDescending("createdAt")

                    return feedItemQuery
                }
            case MEMBERS_INDEX:
                return query
            case STATS_INDEX:
                return query
            default:
                return query
            }
        }*/

        return query
    }
    
    
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        
        if (indexPath.row < self.objects!.count) {
            obj = self.objects![indexPath.row] as? PFObject
        }
        
        return obj
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == DETAILS_SECTION {
            return 2
        }
        return self.objects.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        
        if indexPath.section == DETAILS_SECTION {
        
            if indexPath.row == GROUP_IMAGE_INDEX {
                let cell = tableView.dequeueReusableCellWithIdentifier("groupImageCell") as! PFTableViewCell
                return cell
            }
            else if indexPath.row == GROUP_DESC_INDEX {
                let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailsCell") as! PFTableViewCell
                return cell
            }
            /*else if indexPath.row == SEGMENT_CONTROL_INDEX {
                let cell = tableView.dequeueReusableCellWithIdentifier("header") as! PFTableViewCell
                return cell
            }*/
            /*else if indexPath.row == SEGMENT_CONTROL_INDEX {
                let cell = tableView.dequeueReusableCellWithIdentifier("segmentControlCell") as! PFTableViewCell
                return cell
            }*/
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! GroupFeedUserCell
        let name = object["name"] as! String
        let fbId = object["facebookID"] as! String
        
        cell.nameLabel.text = name
        cell.addUserPhoto(fbId)
        
        return cell
        
    }
    
    func segmentAction(sender: UISegmentedControl) {
        println("segment control switch")

        index = sender.selectedSegmentIndex
        self.loadObjects()
        self.segmentedControl?.selectedSegmentIndex = index
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == DYNAMIC_SECTION {
            let cell = tableView.dequeueReusableCellWithIdentifier("segmentControlCell") as! SegmentationCell
            
            let segmentControl = cell.viewWithTag(1) as! UISegmentedControl
            segmentControl.addTarget(self, action: "segmentAction:", forControlEvents: .ValueChanged)
            segmentControl.selectedSegmentIndex = index
            self.segmentedControl = segmentControl
            //self.loadObjects()
            
            return cell
        }
        return nil
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == DETAILS_SECTION {
            if indexPath.row == 0 {
                return 106
            }
            else if indexPath.row == 1 {
                return 65
            }
        }
        else {
            if let segmentedControl = self.segmentedControl {
                switch segmentedControl.selectedSegmentIndex {
                case FEED_INDEX:
                    return 93
                case MEMBERS_INDEX:
                    return 60
                case STATS_INDEX:
                    return 200
                default:
                    break
                }
            }
            else {
                return 93
            }
        }
        return 0
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == DETAILS_SECTION ? 0 : 42
    }
    
}