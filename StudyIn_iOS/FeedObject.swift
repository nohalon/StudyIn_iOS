//
//  FeedObject.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/10/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

enum FeedObjectType {
    case CHECKIN
    case CHECKOUT
    case STATUSUPDATE
    
    init () {
        self = .CHECKIN
    }
}

class FeedObject {
    var timestamp : NSDate
    var objectType : FeedObjectType
    var objectId : String
    
    init(timestamp : NSDate, objectId : String, type : FeedObjectType) {
        self.timestamp = timestamp
        self.objectId = objectId
        self.objectType = type
    }
}
