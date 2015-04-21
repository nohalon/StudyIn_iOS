//
//  UserCheckInOutCell.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/10/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class UserCheckInOutCell : PFTableViewCell {
    
    @IBOutlet weak var fbProfPic: FBProfilePictureView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkInOutLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIconImg: UIImageView!
    
    let user = User.sharedInstance
    var userPhotoURL : String!

    func setUpCell(userName : String, type : FeedObjectType, location : String, photoURL : String) {
        nameLabel.text = userName
        self.userPhotoURL = photoURL
        locationLabel.sizeToFit()
        
        switch type {
        case .CHECKIN:
            locationIconImg.hidden = false
            locationLabel.hidden = false
            checkInOutLabel.text = "Checking In"
        case .CHECKOUT:
            locationIconImg.hidden = true
            locationLabel.hidden = true
            checkInOutLabel.text = "Checking Out"
        default:
            checkInOutLabel.text = "Error, should not be anything but a check in/out"
        }
        
        checkInOutLabel.sizeToFit()

        locationLabel.text = location
        addUserPhoto()
    }
    
    func addUserPhoto() {
        fbProfPic.profileID = userPhotoURL
        
        self.fbProfPic.layer.cornerRadius = self.fbProfPic.frame.size.width / 2
        self.fbProfPic.clipsToBounds = true
        
        self.fbProfPic.layer.borderWidth = 2.0
        
        var myColor : UIColor = Utils.uicolorFromHex(0x62CDFF)
        self.fbProfPic.layer.borderColor = myColor.CGColor
    }
    
}
