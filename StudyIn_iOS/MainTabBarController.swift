//
//  MainTabBarController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/4/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

}
