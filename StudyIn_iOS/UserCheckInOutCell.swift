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
    
    let user = User.sharedInstance

    func setUpCell() {
        nameLabel.text = user.name
        checkInOutLabel.text = "Checking In"
        checkInOutLabel.sizeToFit()
        locationLabel.sizeToFit()
        locationLabel.text = "Cal Poly Library"
        addUserPhoto()
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
