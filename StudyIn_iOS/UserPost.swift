//
//  UserPost.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class UserPost : FeedObject {
    var statusTxt : String
    var classTxt : String
    var professorTxt : String
    
    init(type : FeedObjectType, objectId: String, timeStamp : NSDate,
        statusText : String, classText : String, professorText : String) {
        
        self.statusTxt = statusText
        self.classTxt = classText
        self.professorTxt = professorText
        
        super.init(timestamp: timeStamp, objectId: objectId, type: type)
    }
}