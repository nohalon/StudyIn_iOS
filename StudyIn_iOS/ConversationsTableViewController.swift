//
//  ConversationsTableViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 4/23/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation
import UIKit

class ConversationsTableViewController : UITableViewController {
    var conversations : [PFObject]?
    let user = User.sharedInstance
    var selectedConvo : PFObject?
    
    @IBOutlet var convosTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = false
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        self.conversations = []
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("loadConversations"), forControlEvents: UIControlEvents.ValueChanged)
        self.convosTable.addSubview(refreshControl)
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadConversations()
    }
    
    
    func loadConversations() {
        var query1 = PFQuery(className: "Conversation")
        query1.whereKey("user1", equalTo: PFObject(withoutDataWithClassName: "StudyInUser",
            objectId: user.parseUserObject.objectId))
        
        var query2 = PFQuery(className: "Conversation")
        query2.whereKey("user2", equalTo: PFObject(withoutDataWithClassName: "StudyInUser",
            objectId: user.parseUserObject.objectId))

        
        var query = PFQuery.orQueryWithSubqueries([query1, query2])
        query.orderByDescending("updatedAt")
        query.includeKey("lastMessage")
        
        query.findObjectsInBackgroundWithBlock {
            [unowned self] (objects, error) -> Void in
            if error == nil {
                self.conversations!.removeAll(keepCapacity: true)
                for object in objects {
                    self.conversations!.append(object as! PFObject)
                }
                self.convosTable.reloadData()
                //self.updateTabCounter()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toMessageView" {
            var messageViewController = segue.destinationViewController as! MessageViewController
            
            let path = self.tableView.indexPathForSelectedRow()!
            self.selectedConvo = conversations![path.row]

            if let messageCell = sender as? ConversationCell {
                messageViewController.groupId = messageCell.groupId!
                messageViewController.otherUserName = messageCell.userName.text
                messageViewController.convoObject = selectedConvo
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToConvoTable(segue:UIStoryboardSegue) {
    
    }
    
}

extension ConversationsTableViewController : UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversations != nil {
            return conversations!.count
        }
        return 0
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("convoCell", forIndexPath: indexPath) as! ConversationCell
        let convo = conversations![indexPath.row]
        
        var otherUserName = ""
        var otherUserPhoto = ""
        
        var user2 = convo["user2"] as! PFObject
        var user1 = convo["user1"] as! PFObject
        
        user1.fetchIfNeededInBackgroundWithBlock {
            [unowned self] (user1Object, error) -> Void in
            if error == nil {
                user2.fetchIfNeededInBackgroundWithBlock {
                    [unowned self] (user2Object, error1) -> Void in
                    if error1 == nil {
                        if (user1Object.objectId == self.user.parseUserObject.objectId) {
                            otherUserName = user2["name"] as! String
                            otherUserPhoto = user2["facebookID"] as! String
                        } else {
                            otherUserName = user1["name"] as! String
                            otherUserPhoto = user1["facebookID"] as! String
                        }
                        
                    }
                }
            }
        }
        
        var lastMessageObj = convo["lastMessage"] as? PFObject
        //lastMessageObj?.fetchIfNeeded()
        var lastMessage = ""
        if lastMessageObj != nil {
            lastMessage = lastMessageObj!["text"] as! String
        }

        /*lastMessageObj.fetchIfNeededInBackgroundWithBlock {
            [unowned self] (message, error) -> Void in
            if error == nil {
            }
        }*/
        
        cell.userImage.profileID = otherUserPhoto
        cell.formatCellImage()
        
        cell.userName.text = otherUserName
        cell.lastMessage.text = lastMessage // TODO: Get actual last message
        cell.groupId = convo["groupId"] as? String
        cell.timeStamp.text = self.getFormattedDate(convo, lastMsg: lastMessageObj) //TODO: Get the formatted date for the last message.
        
        return cell
    }
    
    // Gets a short style formatted date: e.g 11/8/14
    func getFormattedDate(convoObj : PFObject, lastMsg : PFObject?) -> String {
        var date = convoObj.createdAt
        
        //var lastMessage = object["lastMessage"] as? PFObject
        
        var lastMsgDate = lastMsg?.createdAt
        if lastMsgDate != nil {
            date = lastMsgDate
        }
        
        var time = JSQMessagesTimestampFormatter.sharedFormatter().relativeDateForDate(date)
        
        if (time == "Today") {
            time = JSQMessagesTimestampFormatter.sharedFormatter().timeForDate(date)
        }
        else if (time != "Yesterday") {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            
            time = formatter.stringFromDate(date)
        }
        
        return time
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var convo = conversations![indexPath.row] as PFObject
        Utils.deleteMessageItem(convo)
        conversations?.removeAtIndex(indexPath.row)
        convosTable.deleteRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: .Fade)
        //self.updateEmptyView()
        //self.updateTabCounter()
    }

}