//
//  UserCheckInOut.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

enum PostType {
    case CHECKIN
    case CHECKOUT
    
    init () {
        self = .CHECKIN
    }
}

class UserCheckInOut {
    var type : PostType
    var silentPost : Bool
    var location : String
    var timeStamp : NSDate
    
    init(type : PostType, silentPost : Bool, location : String, timeStamp : NSDate) {
        self.type = type
        
        switch type {
        case .CHECKIN:
            self.location = location
        case .CHECKOUT:
            self.location = ""
        }
        
        self.silentPost = silentPost
        self.timeStamp = timeStamp
    }
}