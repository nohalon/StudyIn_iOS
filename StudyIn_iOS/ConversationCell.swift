//
//  MessageCell.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 4/21/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var userImage: FBProfilePictureView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    var groupId: String?
    
    func formatCellImage() {
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        self.userImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.userImage.layer.borderWidth = 0.85
        self.userImage.layer.borderColor = Utils.uicolorFromHex(0x62CDFF).CGColor
    }
}
