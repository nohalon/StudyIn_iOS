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
        query.includeKey("user")
        query.includeKey("checkOut")
        query.includeKey("checkOut.location")
        query.includeKey("checkIn")
        query.includeKey("checkIn.location")
        query.includeKey("statusUpdate")
        query.includeKey("statusUpdate.course")
        query.includeKey("statusUpdate.professor")
        
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
        //let group = groups[indexPath.row]
        cell.groupName.text = groupName
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let group = groups[indexPath.row] as PFObject
        
        Utils.deleteGroupItem(user.parseUserObject, group: group) // remove from parse
        
        groups.removeAtIndex(indexPath.row)
        groupsTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
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
    }
    
    @IBAction func unwindToGroupsTable(segue:UIStoryboardSegue) {
        
    }
}

/*extension GroupsTableViewController : UITableViewDataSource {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! GroupCell
        
        let group = groups[indexPath.row]
        cell.groupName.text = group["name"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups != nil {
            return groups.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let group = groups[indexPath.row] as PFObject
        
        Utils.deleteGroupItem(user.parseUserObject, group: group) // remove from parse
        
        groups.removeAtIndex(indexPath.row)
        groupsTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
    }
}*/

/* class GroupsTableViewController: UITableViewController {

@IBOutlet var groupsTable: UITableView!
var groups : [PFObject]!
let user = User.sharedInstance

override func viewDidLoad() {
super.viewDidLoad()

groups = []
loadGroups()
// Do any additional setup after loading the view.
}

func loadGroups() {
var groupsRelation = user.parseUserObject.relationForKey("groups") as PFRelation

groupsRelation.query().findObjectsInBackgroundWithBlock {
[unowned self] (groupsObj, error) -> Void in
if error == nil {
for group in groupsObj {
if find(self.groups, group as! PFObject) ==  nil {
self.groups.append(group as! PFObject)
}
}
self.groupsTable.reloadData()
}
else {
println(error)
}
}
}

override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}

func reloadTable() {
loadGroups()
self.groupsTable.reloadData()
}

override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
if (segue.identifier == "unwindToGroupsTable") {
loadGroups()
self.groupsTable.reloadData()
}
}

@IBAction func unwindToGroupsTable(segue:UIStoryboardSegue) {

}
}

extension GroupsTableViewController : UITableViewDataSource {

override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
return 1
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
var cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! GroupCell

let group = groups[indexPath.row]
cell.groupName.text = group["name"] as? String

return cell
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
if groups != nil {
return groups.count
}
return 0
}

override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
let group = groups[indexPath.row] as PFObject

Utils.deleteGroupItem(user.parseUserObject, group: group) // remove from parse

groups.removeAtIndex(indexPath.row)
groupsTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
}
}*/
