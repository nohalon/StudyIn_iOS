//
//  StatusCheckIn.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/8/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

public class StatusCheckIn {
    var checkInTime = NSDate()
    var checkOutTime = NSDate()
    var statusTxt : String = ""
    var course : String = ""
    var professor : String = ""
    var privateCheckIn : Bool = false
    
    init (checkInTime : NSDate, statusTxt : String, course : String, professor : String, privateCheckIn : Bool) {
        self.checkInTime = checkInTime
        self.statusTxt = statusTxt
        self.course = course
        self.professor = professor
        self.privateCheckIn = privateCheckIn
    }
    
    func setCheckOutTime(checkOutTime : NSDate) {
        self.checkOutTime = checkOutTime
    }
}