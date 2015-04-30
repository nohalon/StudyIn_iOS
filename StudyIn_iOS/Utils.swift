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
    
    
    class func createMessageItem(user1: PFObject, user2: PFObject, groupId: String) -> PFObject {
        var query = PFQuery(className: "Conversation")
        query.whereKey("user1", equalTo: PFObject(withoutDataWithClassName: "StudyInUser", objectId: user1.objectId))
        query.whereKey("groupId", equalTo: groupId)
        var message = PFObject(className: "Conversation")
        
        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]!, error: NSError!) in
            if error == nil {
                if objects.count == 0 {
                    message["user1"] = user1
                    message["groupId"] = groupId
                    message["user2"] = user2
                    //message["messages"] = []
                    message["counter"] = 0
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
    
    class func deleteMessageItem(message: PFObject) {
        message.deleteInBackgroundWithBlock { (succeeded, error) -> Void in
            if (error != nil) {
                NSLog("delete message item delete error.")
            }
        }
    }
}
