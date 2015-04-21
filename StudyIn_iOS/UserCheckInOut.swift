//
//  UserCheckInOut.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class UserCheckInOut : FeedObject {
    var type : FeedObjectType
    var silentPost : Bool
    var location : String! = ""
    
    init(type : FeedObjectType, timeStamp : NSDate, objectId : String, silentPost : Bool, location : String) {
        self.type = type
        
        switch type {
        case .CHECKIN:
            self.location = location
        case .CHECKOUT:
            self.location = ""
        case .STATUSUPDATE:
            self.location = ""
        }
        
        self.silentPost = silentPost
        super.init(timestamp: timeStamp, objectId: objectId, type: type)
    }
}