    //
//  MessageViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 4/21/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class MsgUser {
    var fbId: String = ""
    var name: String = ""
    var image: UIImage!
    
    
    init(id: String, name: String, image: UIImage) {
        self.fbId = id
        self.name = name
        self.image = image
    }
}

class MessageViewController : JSQMessagesViewController {
    let user = User.sharedInstance
    var groupId: String!
    var otherUserName: String!
    var convoObject : PFObject?
    var refreshControl : UIRefreshControl!

    var timer: NSTimer?
    var isLoading: Bool!
    
    var users: [MsgUser]!
    var messages: [JSQMessage]!
    var avatars: [String: JSQMessagesAvatarImage]!
    
    var bubbleImageOutgoing: JSQMessagesBubbleImage!
    var bubbleImageIncoming: JSQMessagesBubbleImage!
    var avatarImageBlank: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoading = false
        
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = otherUserName
        
        self.users = []
        self.messages = []
        self.avatars = Dictionary<String, JSQMessagesAvatarImage>()
        
        var bubbleFactory = JSQMessagesBubbleImageFactory()
        self.bubbleImageOutgoing = bubbleFactory.outgoingMessagesBubbleImageWithColor(Utils.uicolorFromHex(0x62CDFF))
        self.bubbleImageIncoming = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        var image = UIImage(named: "chat_blank")
        self.avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
        
        super.senderDisplayName = self.user.name
        super.senderId = self.user.parseUserObject["facebookID"] as! String
        
        // Set up refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "pullMessages:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        self.loadMessages(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("callLoadMessages"), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        timer?.invalidate()
        
        self.tabBarController?.tabBar.hidden = false
        super.viewWillDisappear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    func pullMessages(sender: UIRefreshControl) {
        println("pulling messgaes")
        self.loadMessages(true)
        self.refreshControl.endRefreshing()
    }
    
    func callLoadMessages() {
        loadMessages(false)
    }
    
    func loadMessages(var isRefreshing : Bool) {
        if (isRefreshing && self.messages.count > 0) || !isRefreshing {
            if self.isLoading == false {
                self.isLoading = true
                var lastMessage = self.messages.last
                
                var query = PFQuery(className: "Message")
                query.whereKey("groupId", equalTo: self.groupId)
                //query.whereKey("conversation", equalTo: convoObject)
                
                if isRefreshing {
                    if messages.first != nil {
                        query.whereKey("createdAt", lessThan: messages.first?.date)
                    }
                }
                else {
                    if lastMessage != nil {
                        query.whereKey("createdAt", greaterThan: lastMessage?.date)
                    }
                }
                
                // Gets the most recent items in reverse order
                query.orderByDescending("createdAt")
                query.limit = 10
                
                query.findObjectsInBackgroundWithBlock({
                    [unowned self] (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        
                        self.automaticallyScrollsToMostRecentMessage = false
                        for object in objects {
                            self.addMessage(object as! PFObject)
                        }
                        
                        if self.messages.count != 0 {
                            self.finishReceivingMessage()
                        }
                        
                        // Scroll to bottom if a new message has been recieved
                        if objects.count > 0 {
                            self.scrollToBottomAnimated(true)
                        }
                        
                    } else {
                        println("Error retrieving messages")
                    }
                    
                    /*if isRefreshing {
                        self.refreshControl.endRefreshing()
                    }*/
                    self.isLoading = false
                    })
            }
        }
    }
    
    func addMessage(var object: PFObject) {
        var user = object["user"] as! PFObject
        
        var fbId = user["facebookID"] as! String
        var userName = user["name"] as! String
        var message = JSQMessage(senderId: fbId, senderDisplayName: userName, date: object.createdAt, text: object["text"] as! String)
        
        let imageUrl = NSURL(string: "https://graph.facebook.com/\(fbId)/picture?type=small")
        if let data = NSData(contentsOfURL: imageUrl!) {
            var userImage = UIImage(data: data)
            var user = MsgUser(id: fbId, name: userName, image: userImage!)
            self.users.insert(user, atIndex: 0)
        }
        self.messages.insert(message, atIndex: 0)
    }
    
    func sendMessage(text: String) {
        // Save a Message object to Parse
        var object = PFObject(className: "Message")
        object["user"] = self.user.parseUserObject
        object["groupId"] = self.groupId
        object["text"] = text
        var msgCount : Int! = PFCloud.callFunction("messageCount", withParameters: [:]) as! Int
        object["integerID"] = (msgCount + 1)
        
        object.saveInBackgroundWithBlock {
            [unowned self] (success: Bool, error: NSError!) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                
                // Save the latest message
                self.convoObject!["lastMessage"] = object
                self.convoObject!.saveInBackground()
                
                self.loadMessages(false)
            } else {
                println("Error sending message")
            }
        }
        
        //Util.sendPushNotification(self.user.id, groupId: groupId, text: text)
        //Util.updateMessageCounter(self.user.id, groupId: groupId, lastMessage: text)
        
        self.finishSendingMessage()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.sendMessage(text)
    }
    
    // JSQMessagesCollectionViewDataSource overrides.
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return bubbleImageOutgoing
        }
        
        return bubbleImageIncoming
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        var user = users[indexPath.item]
        if avatars[user.fbId] == nil {
            var fileThumnnail = PFFile(data: UIImageJPEGRepresentation(user.image, 1.0))
            fileThumnnail.getDataInBackgroundWithBlock({
                (imageData, error) -> Void in
                if error == nil {
                    self.avatars[user.fbId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData), diameter: 30)
                    self.collectionView.reloadData()
                }
            })
            
            return self.avatarImageBlank
        } else {
            return avatars[user.fbId]
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            var message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    /*override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            var previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }*/
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // UICollectionViewDataSource overrides.
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        var message = messages[indexPath.item]
        
        if message.senderId != self.senderId {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    // JSQMessagesCollectionViewFlowLayoutDelegate overrides.
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return 20.0
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            var previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        return 20.0
    }
}