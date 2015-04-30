//
//  UserPostCell.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/9/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class UserPostCell : PFTableViewCell {
    
    @IBOutlet weak var fbProfPic: FBProfilePictureView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    let user = User.sharedInstance
    var userPhotoURL : String!

    func setUpCell(userName: String, statusText : String, course : String, professor : String, photoURL : String) {
        self.userPhotoURL = photoURL
        
        //var myStatus = statusText + "\n\n"
        //var myCourse = "Course: " + course + "\n"
        //var myProf = "Professor: " + professor
        
        nameLabel.text = userName
        postLabel.numberOfLines = 0
        
        postLabel.sizeToFit()
        postLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        
        var postStr = constructAttributedPostText(statusText, strCourse: course, strProf: professor)

        postLabel.attributedText = postStr

        addUserPhoto()
    }
    
    // Constructs the text to be displayed as a post with some text attributes
    func constructAttributedPostText(strStatus : String, strCourse : String, strProf : String) -> NSMutableAttributedString {
        
        var myStatus = strStatus + "\n"
        var entirePost = myStatus
        var postStr = NSMutableAttributedString(string: myStatus)
    
        if strCourse != "" {
            var course = "\nCourse: " + strCourse
            var myCourse = NSMutableAttributedString(string: course)
            var rangeLocClass = count(myStatus) // skip new line characters
            var lengthClass = 7 // length of word "Course:"
            
            postStr.appendAttributedString(myCourse)
            postStr.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSRange(location:rangeLocClass,length:lengthClass))
            
            entirePost += course
        }
        if strProf != "" {
            var prof = "\nProfessor: " + strProf
            var myProf = NSMutableAttributedString(string: prof)
            var rangeLocProfessor = count(entirePost)  // skip new line characters
            var lengthProfessor = 10 // length of word "Professor:"
            
            postStr.appendAttributedString(myProf)
            postStr.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSRange(location:rangeLocProfessor,length:lengthProfessor))
            
            entirePost += prof
        }
        
        return postStr
    }
    
    func addUserPhoto() {
        fbProfPic.profileID = userPhotoURL
        
        self.fbProfPic.layer.cornerRadius = self.fbProfPic.frame.size.width / 2
        self.fbProfPic.clipsToBounds = true
        
        self.fbProfPic.layer.borderWidth = 0.85
        
        var myColor : UIColor = Utils.uicolorFromHex(0x62CDFF)
        self.fbProfPic.layer.borderColor = myColor.CGColor
    }
    
}
