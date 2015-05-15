//
//  MessageComposer.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 4/24/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class UserCell : UITableViewCell {
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

class MessageComposer : UITableViewController, UITableViewDataSource {
    let user = User.sharedInstance
    var users : [PFObject]?
    var lastSelectedIndexPath : NSIndexPath?
    var groupId : String?
    var selectedUser : PFObject?
    var convoObj : PFObject?
    @IBOutlet var userTable: UITableView!
    
    
    override func viewDidLoad() {
        self.users = []
        self.userTable.delegate = self
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonAction:")
        //self.navigationItem.backBarButtonItem = backButton
        
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = "New Message"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "sendMessageAction:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers()
    }
    
    func backButtonAction(sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func sendMessageAction(sender: UIBarButtonItem) {
        if let theSelectedUser = selectedUser {
            self.groupId = Utils.startChat(self.user.parseUserObject, user2: theSelectedUser)
            self.convoObj = Utils.createMessageItem(self.user.parseUserObject, user2: theSelectedUser, groupId: self.groupId!)
            
            performSegueWithIdentifier("toMessageView", sender: self)
        }
    }
    
    func loadUsers() {
        var query = PFQuery(className: "StudyInUser")
        query.selectKeys(["name", "facebookID"])
        
        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]!, error: NSError!) in
            if objects.count != 0 {
                for user in objects {
                    self.users?.append(user as! PFObject)
                }
                self.userTable.reloadData()
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMessageView" {
            var messageViewController = segue.destinationViewController as! MessageViewController
            messageViewController.groupId = self.groupId
            messageViewController.convoObject = self.convoObj
            self.navigationItem.title = nil
            if let theSelectedUser = selectedUser {
                messageViewController.otherUserName = theSelectedUser["name"] as! String
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserCell
        cell.accessoryType = (lastSelectedIndexPath?.row == indexPath.row) ? .Checkmark : .None
        let myUser = users![indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        cell.nameLabel.text = myUser["name"] as? String
        cell.addUserPhoto(myUser["facebookID"] as! String)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != lastSelectedIndexPath?.row {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = .None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            lastSelectedIndexPath = indexPath
            self.selectedUser = users![indexPath.row]
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil {
            return users!.count
        }
        return 0;
    }
}