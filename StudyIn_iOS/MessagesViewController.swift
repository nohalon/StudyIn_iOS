//
//  MessagesViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation
import UIKit

class MessagesTableViewController: UITableViewController {
    var conversations : [PFObject]?
    //var messagesQuery : PFQuery
    let user = User.sharedInstance
    
    @IBOutlet var messageTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        self.conversations = []
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("loadMessages"), forControlEvents: UIControlEvents.ValueChanged)
        self.messageTable.addSubview(refreshControl)
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
    }
    
    func loadMessages() {
        var query = PFQuery(className: "Messages")
        
        /*query.includeKey("user")
        query.includeKey("otherUser")
        query.includeKey("lastMessage")
        query.includeKey("groupId")
        query.includeKey("counter")*/
        
        //TODO: update to my DB model
        query.whereKey("userFrom", equalTo: PFObject(withoutDataWithClassName: "StudyInUser",
            objectId: user.parseUserObject.objectId))
        
        query.orderByDescending("updatedAction")
        query.findObjectsInBackgroundWithBlock {
            [unowned self] (objects, error) -> Void in
            if error == nil {
                self.messages!.removeAll(keepCapacity: true)
                for object in objects {
                    self.messages!.append(object as! PFObject)
                }
                self.messageTable.reloadData()
                //self.updateTabCounter()
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toMessageView" {
            var messageViewController = segue.destinationViewController as! MessageViewController
            
            if let messageCell = sender as? MessageCell {
                //messageViewController.groupId = messageCell.groupId
                //messageViewController.user = self.user
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MessagesTableViewController : UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages!.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageCell
        let message = messages![indexPath.row]
        
        cell.userName.text = message["otherUserName"] as? String
        let otherUserId = message["otherUserId"] as? String
        
        let imageUrl = NSURL(string: "https://graph.facebook.com/\(otherUserId!)/picture?type=large")
        if let data = NSData(contentsOfURL: imageUrl!) {
            cell.userImage.image = UIImage(data: data)
            cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
            cell.userImage.clipsToBounds = true
            cell.userImage.contentMode = UIViewContentMode.ScaleAspectFill
        }
        cell.lastMessage.text = message["lastMessage"] as? String
        cell.groupId = message["groupId"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var message = messages![indexPath.row] as PFObject
        Utils.deleteMessageItem(message)
        messages?.removeAtIndex(indexPath.row)
        messageTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
        //self.updateEmptyView()
        //self.updateTabCounter()
    }
}
