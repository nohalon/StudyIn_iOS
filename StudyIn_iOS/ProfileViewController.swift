//
//  ProfileViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profilePictureView: FBProfilePictureView!
    @IBOutlet weak var userNameLbl: UILabel!
    let user = User.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadUserDetails()
    }
    
    func loadUserDetails() {
        profilePictureView.profileID = user.profilePicture
        userNameLbl.text = user.name
        
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
        self.profilePictureView.clipsToBounds = true;
        
        self.profilePictureView.layer.borderWidth = 2.0;
        var myColor : UIColor = uicolorFromHex(0x62CDFF)
        self.profilePictureView.layer.borderColor = myColor.CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSettingsActionSheet(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            FBSession.activeSession().closeAndClearTokenInformation()
            self.performSegueWithIdentifier("unwindFromProfile", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
