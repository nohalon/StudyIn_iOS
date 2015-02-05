//
//  User.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/4/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

class User {
    
    let userName : String = ""
    let userEmail : String = ""
    let userProfilePicture : String = "";
    
    init(name : String, email : String, profilePicture : String) {
        self.userName = name
        self.userEmail = email
        self.userProfilePicture = profilePicture
    }
}
