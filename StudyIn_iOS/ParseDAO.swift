//
//  ParseDAO.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/19/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class ParseDAO {
    let user = User.sharedInstance

    // Get all the status updates from the DB.
    // TODO: Get the status updates that the user has permission to see.
    func getAllPosts() -> [PFObject] {
        var statusUpdateQuery = PFQuery(className: "StatusUpdate")
        let statusUpdates = statusUpdateQuery.findObjects() as! [PFObject]!
        return statusUpdates
    }
    
    // Gets all check ins from the DB.
    // TODO: Get the check ins that the user has permission to see.
    func getAllCheckIns() -> [PFObject] {
        var checkInQuery = PFQuery(className: "CheckIn")
        checkInQuery.includeKey("location")
        let checkIns = checkInQuery.findObjects() as! [PFObject]!
        return checkIns
    }
    
    // Gets all check outs from the DB.
    // TODO: Get the check outs that the user has permission to see.
    func getAllCheckOuts() -> [PFObject] {
        var checkOutQuery = PFQuery(className: "CheckOut")
        checkOutQuery.includeKey("checkIn.location")
        let checkOuts = checkOutQuery.findObjects() as! [PFObject]!
        return checkOuts
    }
    
    // Saves the current post to the Parse Database.
    func savePostToParse(statusText : String, course : PFObject, prof : PFObject) {
        var postObject = PFObject(className: "StatusUpdate")
        var postCount: Int! = PFCloud.callFunction("statusUpdateCount", withParameters: [:]) as! Int
        
        postObject["integerId"] = postCount + 1
        postObject["user"] = self.user.parseUserObject
        postObject["statusText"] = statusText
        postObject["course"] = course
        postObject["professor"] = prof
        postObject.saveInBackground()
        
        saveFeedItem("statusUpdate", saveObject: postObject)
    }
    
    func saveFeedItem(fieldName: String, saveObject: PFObject) {
        var feedItemObject = PFObject(className: "FeedItem")
        var feedCount : Int! = PFCloud.callFunction("feedItemCount", withParameters: [:]) as! Int
        feedItemObject["integerID"] = feedCount + 1
        feedItemObject["user"] = self.user.parseUserObject
        feedItemObject[fieldName] = saveObject
        feedItemObject.saveInBackground()
    }
    
    // Returns a location object that already exists in the database or a creates one and returns it.
    func getLocationParseObj(location : String) -> PFObject {
        var locObject = PFObject(className: "Location")
        
        var testquery = PFQuery(className:"Location")
        testquery.whereKey("name", equalTo: location)
        var objects = testquery.findObjects()
        
        if (objects.count == 0) {
            // save object
            locObject["name"] = location
            locObject.saveInBackground()
        }
        else {
            locObject = objects[0] as! PFObject
        }
        
        return locObject
    }
    
    // Returns a Course object that already exists in the database or a creates one and returns it.
    func getCourseParseObj(courseName : String) -> PFObject {
        var courseObj = PFObject(className: "Course")
        
        var testquery = PFQuery(className:"Course")
        testquery.whereKey("courseName", equalTo: courseName)
        var objects = testquery.findObjects()
        
        if (objects.count == 0) {
            // save object
            courseObj["courseName"] = courseName
            courseObj.saveInBackground()
        }
        else {
            courseObj = objects[0] as! PFObject
        }
        
        return courseObj
    }
    
    // Returns a Professor object that already exists in the database or a creates one and returns it.
    func getProfessorParseObj(profName : String) -> PFObject {
        var profObj = PFObject(className: "Professor")
        
        var testquery = PFQuery(className:"Professor")
        testquery.whereKey("professorName", equalTo: profName)
        var objects = testquery.findObjects()
        
        if (objects.count == 0) {
            // save object
            profObj["professorName"] = profName
            profObj.saveInBackground()
        }
        else {
            profObj = objects[0] as! PFObject
        }
        
        return profObj
    }
    
    // Saves the current Check In to the Parse database.
    func saveCheckInToParse(location : PFObject) {
        var checkInObject = PFObject(className: "CheckIn")
        var result: Int! = PFCloud.callFunction("checkInCount", withParameters: [:]) as! Int
        
        checkInObject["integerId"] = result + 1
        checkInObject["location"] = location
        checkInObject["user"] = self.user.parseUserObject
        checkInObject.saveInBackground()
        
        saveFeedItem("checkIn", saveObject: checkInObject)

        user.parseActiveCheckIn = checkInObject
    }
    
    // Saves a the current Check Out to the parse database.
    func saveCheckOutToParse() {
        var checkOutObject = PFObject(className: "CheckOut")
        var result: Int! = PFCloud.callFunction("checkOutCount", withParameters: [:]) as! Int
        
        checkOutObject["user"] = user.parseUserObject
        checkOutObject["checkIn"] = user.parseActiveCheckIn
        checkOutObject["integerId"] = result + 1
        checkOutObject.saveInBackground()
        
        saveFeedItem("checkOut", saveObject: checkOutObject)
    }
}