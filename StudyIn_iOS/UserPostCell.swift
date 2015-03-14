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

    func setUpCell() {
        nameLabel.text = user.name
        postLabel.numberOfLines = 0
        
        postLabel.sizeToFit()
        postLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        //postLabel.text = "Short post test"
        var strPost = "This is an example of a user post that is supposed to be supppperrr duper long I want to see if it will resize the label text to fill the table view cell, this is a stupid test. blah blah blah. good that should be enough :)"
        var strClass = "\n\nClass: Math 141"
        var strProfessor = "\nProfessor: Mendes"
        
        var postStr = constructAttributedPostText(strPost, strClass: strClass, strProf: strProfessor)

        postLabel.attributedText = postStr

        addUserPhoto()
    }
    
    // Constructs the text to be displayed as a post with some text attributes
    func constructAttributedPostText(strPost : String, strClass : String, strProf : String) -> NSMutableAttributedString {
        var rangeLocClass = count(strPost) + 1 // skip new line characters
        var lengthClass = 6 // length of word "Class:"
        
        var rangeLocProfessor = count(strPost + strClass) + 1  // skip new line characters
        var lengthProfessor = 10 // length of word "Professor:"
        
        var postStr = NSMutableAttributedString(string: strPost + strClass + strProf)
        postStr.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSRange(location:rangeLocClass,length:lengthClass))
        
        postStr.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Bold", size: 12.0)!, range: NSRange(location:rangeLocProfessor,length:lengthProfessor))
        
        return postStr
    }
    
    func addUserPhoto() {
        fbProfPic.profileID = user.profilePicture
        
        self.fbProfPic.layer.cornerRadius = self.fbProfPic.frame.size.width / 2
        self.fbProfPic.clipsToBounds = true
        
        self.fbProfPic.layer.borderWidth = 2.0
        
        var myColor : UIColor = Utils.uicolorFromHex(0x62CDFF)
        self.fbProfPic.layer.borderColor = myColor.CGColor
    }
    
}
