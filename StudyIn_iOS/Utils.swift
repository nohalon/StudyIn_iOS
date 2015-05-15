//
//  Utils.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/10/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class Utils {
    
    class func startChat(user1: PFObject, user2: PFObject) -> String {
        var userId1 = user1.objectId
        var userId2 = user2.objectId
        
        var groupId = userId1.compare(userId2).hashValue < 0 ? userId1 + userId2 : userId2 + userId1
        
        //createMessageItem(user1, user2: user2, groupId: groupId)
        //createMessageItem(userTo, userTo: userFrom, groupId: groupId)
        
        return groupId
    }
    
    // Shows an alert view with a given title and message
    class func showAlertViewWithMessage(sender: UIViewController, title : String, message : String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        sender.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func createMessageItem(user1: PFObject, user2: PFObject, groupId: String) -> PFObject {
        var query = PFQuery(className: "Conversation")
        query.whereKey("user1", equalTo: PFObject(withoutDataWithClassName: "StudyInUser", objectId: user1.objectId))
        query.whereKey("groupId", equalTo: groupId)
        var message = PFObject(className: "Conversation")
        var convoCount : Int! = PFCloud.callFunction("conversationCount", withParameters: [:]) as! Int
        
        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]!, error: NSError!) in
            if error == nil {
                if objects.count == 0 {
                    message["user1"] = user1
                    message["groupId"] = groupId
                    message["user2"] = user2
                    //message["messages"] = []
                    message["counter"] = 0
                    message["intgerID"] = (convoCount + 1)
                    message["updatedAction"] = NSDate()
                    message.saveInBackgroundWithBlock({
                        (succeeded, error) -> Void in
                        if error != nil {
                            NSLog("Save error in createMessageItem")
                        }
                    })
                }
                else {
                    message = objects[0] as! PFObject
                }
            } else {
                NSLog("Query error in createMessageItem")
            }
        })
        
        return message
    }
    
    class func updateMessageCounter(currentUserId: String, groupId: String, lastMessage: String) {
        var query = PFQuery(className: "Messages")
        query.whereKey("groupId", equalTo: groupId)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                for object in objects {
                    var message = object as! PFObject
                    var lastUserId = message["lastUserId"] as! String
                    if lastUserId != currentUserId {
                        message.incrementKey("counter", byAmount: 1)
                        message["lastUserId"] = currentUserId
                        message["updatedAction"] = NSDate()
                        
                    }
                    if message["lastMessage"] as! String != lastMessage {
                        message["lastMessage"] = lastMessage
                        message["updatedAction"] = NSDate()
                    }
                    
                    message.saveInBackgroundWithBlock({
                        (succeeded, error) -> Void in
                        if error != nil {
                            NSLog("Save error in updateMessageCounter")
                        }
                    })
                }
            }
        }
    }
    
    // Converts a hexadecimal value to an RGB UIColor.
    class func uicolorFromHex(rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    class func deleteGroupItem(user: PFObject, group: PFObject) {
        let relation = user.relationForKey("groups") as PFRelation
        relation.removeObject(group)
        user.saveInBackground()
    }
    
    class func deleteMessageItem(message: PFObject) {
        message.deleteInBackgroundWithBlock { (succeeded, error) -> Void in
            if (error != nil) {
                NSLog("delete message item delete error.")
            }
        }
    }
    
    class func saveGroupToParse(name: String, description: String, image: UIImageView) {
        let user = User.sharedInstance
        var group = PFObject(className: "Group")
        let groupCount: Int! = PFCloud.callFunction("groupCount", withParameters: [:]) as! Int
        
        let imageData = UIImageJPEGRepresentation(image.image, 0.8)
        let imageFile = PFFile(name: name + ".png", data: imageData)
        
        group["integerId"] = groupCount + 1
        group["name"] = name
        group["description"] = description
        group.addObject(user.parseUserObject.objectId, forKey: "adminIDs")
        group.setObject(imageFile, forKey: "image")
        group.saveInBackgroundWithBlock {
             (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.addUserToRelationForGroup(user.parseUserObject, group: group)
                self.addGroupToRelationForUser(group, user: user.parseUserObject)
            }
            else {
                println("error with saving new group to parse")
            }
        }
        
    }
    
    class func addUserToRelationForGroup(user: PFObject, group: PFObject) {
        var usersRelation = group.relationForKey("users")
        usersRelation.addObject(user)
        group.saveInBackground()
    }
    
    class func addGroupToRelationForUser(group: PFObject, user: PFObject) {
        var groupsRelation = user.relationForKey("groups")
        groupsRelation.addObject(group)
        user.saveInBackground()
    }
}
