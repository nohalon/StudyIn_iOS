//
//  UserPost.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class UserPost {
    var statusTxt : String
    var classTxt : String
    var professorTxt : String
    var timeStamp : NSDate
    
    init(statusText : String, classText : String, professorText : String, timeStamp : NSDate) {
        self.statusTxt = statusText
        self.classTxt = classText
        self.professorTxt = professorText
        self.timeStamp = timeStamp
    }
}