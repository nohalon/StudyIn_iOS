//
//  GroupsViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class GroupCell : PFTableViewCell {
    @IBOutlet weak var groupName: UILabel!
}


class GroupsTableViewController: PFQueryTableViewController {

    @IBOutlet var groupsTable: UITableView!
    var groups : [PFObject]!
    let user = User.sharedInstance
    var selectedGroup : PFObject?
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }

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
        var groupsRelation = user.parseUserObject.relationForKey("groups") as PFRelation
        var query = groupsRelation.query()
        
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
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! GroupCell
        var groupName = object["name"] as! String
        cell.groupName.text = groupName
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let group = self.objects[indexPath.row] as! PFObject
        
        //groupsTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
        Utils.deleteGroupItem(user.parseUserObject, group: group) // remove from parse

        self.loadObjects()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toGroupSegue", sender: self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTable() {
        self.loadObjects()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "unwindToGroupsTable") {
            self.loadObjects()
        }
        else if (segue.identifier == "toGroupSegue") {
            
            let path = self.tableView.indexPathForSelectedRow()!
            self.selectedGroup = self.objects[path.row] as? PFObject
            
            var groupViewController = segue.destinationViewController as! GroupContentViewController
            if let theSelectedGroup = self.selectedGroup {
                groupViewController.group = theSelectedGroup
            }
        }
    }
    
    @IBAction func unwindToGroupsTable(segue:UIStoryboardSegue) {
        self.loadObjects()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}