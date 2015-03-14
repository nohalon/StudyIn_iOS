//
//  StatusUpdateViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit
import CoreLocation

class StatusCheckInViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var statusTxt: UITextField!
    @IBOutlet var classTxt: UITextField!
    @IBOutlet var professorTxt: UITextField!
    @IBOutlet var privatePostSwitch: UISwitch!
    @IBOutlet var checkInBtn: UIButton!
    @IBOutlet var locationLabel: UILabel!
    
    let user = User.sharedInstance
    var delegate : HomeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusTxt.delegate = self;
        self.classTxt.delegate = self;
        self.professorTxt.delegate = self;
        
        self.statusTxt.becomeFirstResponder()
    }

    override func viewDidAppear(animated : Bool) {
        super.viewDidAppear(animated)
        statusTxt.becomeFirstResponder()
    }
    
    // Create the UIToolBar and append to keyboard on page load
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        var checkInOutItem = UIBarButtonItem();
        let postItem = setUpBarBtn("POST", actionName: "postAction")
        
        if user.isCheckedIn == false {
            // Create "check in" bar button item
            checkInOutItem = setUpBarBtn("CHECK IN", actionName: "checkInAction")
        }
        else {
            // Create "check out" bar button item
            checkInOutItem = setUpBarBtn("CHECK OUT", actionName: "checkOutAction")
        }
        
        var toolbarButtons : [UIBarButtonItem] = [postItem, checkInOutItem]
        
        //Put the buttons into the ToolBar and display the tool bar
        toolBar.setItems(toolbarButtons, animated: false)
        textField.inputAccessoryView = toolBar
        
        return true
    }
    
    // Creates the a Bar Button Item given it's label text and action text
    func setUpBarBtn(textLabel : String, actionName : String) -> UIBarButtonItem {
        let screenSize : CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        
        let buttonItemImg : UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonItemImg.titleLabel?.tintColor = UIColorFromRGB(0xFFFFFF)
        
        if let font = UIFont(name: "Lato", size: 15) {
            buttonItemImg.titleLabel?.font = font;
        }
        
        buttonItemImg.setTitle(textLabel, forState: .Normal)
        buttonItemImg.backgroundColor = UIColorFromRGB(0x62CDFF)
        buttonItemImg.frame = CGRectMake(0, 0, (screenWidth / 2) - 20, 35)
        
        var actionSelector : Selector = Selector(actionName)
        buttonItemImg.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.TouchUpInside)

        let buttonItem : UIBarButtonItem = UIBarButtonItem(customView: buttonItemImg)
        
        return buttonItem
    }
    
    // Event handler for post action
    func postAction() {
        var currentTime = NSDate();
        var statusText = self.statusTxt.text ?? "";
        var classText = self.classTxt.text ?? "";
        var professorText = self.professorTxt.text ?? "";
        
        var post : UserPost = UserPost(statusText : statusText, classText : classText, professorText : professorText, timeStamp : currentTime)
        
        user.userPosts.append(post)
        
        //self.delegate.updateView()
        self.performSegueWithIdentifier("UnwindToHomeSegue", sender : self)
        
        // set the delegate of the homeviewcontroller
        // save to parse
        // check if location is already in the location table
            // it it is
            // find and get it from parse
            // it its not, create it
    }
    
    // Event handler for check-in action
    func checkInAction () {
        var currentTime = NSDate();
        var locationLabel = self.locationLabel.text!
        
        if (locationLabel != "Name your location") {
            user.isCheckedIn = true;
            var checkIn = UserCheckInOut(type : .CHECKIN, silentPost : isPrivateCheckIn(), location : locationLabel, timeStamp : currentTime);
            user.userCheckInOuts.append(checkIn);
            self.performSegueWithIdentifier("UnwindToHomeSegue", sender : self)
        }
        else {
            showAlertViewWithMessage("Your New Check In", message : "Hey there, we ask that you please specify your location when you want to check in, thanks!")
        }
        
        // Save post information as well
        //postAction();
    }
    
    // Event handler for check-out action
    func checkOutAction() {
        var currentTime = NSDate();
        var locationLabel = self.locationLabel.text!
        
        if (locationLabel != "Name your location") {
            user.isCheckedIn = true;
            var checkOut = UserCheckInOut(type : .CHECKOUT, silentPost : isPrivateCheckIn(), location : locationLabel, timeStamp : currentTime);
            user.userCheckInOuts.append(checkOut);
            self.performSegueWithIdentifier("UnwindToHomeSegue", sender : self)
        }
        else {
            showAlertViewWithMessage("Your New Check Out", message : "Hey there, we ask that you please specify your location when you want to check out, thanks!")
        }
    }
    
    // Shows an alert view with a given title and message
    func showAlertViewWithMessage(title : String, message : String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check if user wants to check in privately
    func isPrivateCheckIn() -> Bool {
        var privateCheckIn = false
        
        if (privatePostSwitch.on) {
            privateCheckIn = true
        }
        
        return privateCheckIn
    }

    // Save the check in information and create a new StatusCheckIn object
    @IBAction func checkInBtnClick(sender: UIButton) {
        var currentTime =  NSDate()
        var privateCheckIn = isPrivateCheckIn()
        //var newStatusCheckIn : StatusCheckIn = StatusCheckIn(checkInTime: currentTime, statusTxt:
            //statusTxt.text, course: classTxt.text, professor: professorTxt.text, privateCheckIn: privateCheckIn)
        
        user.isCheckedIn = true
        //user.checkIns.append(newStatusCheckIn)
        
        // Save to Parse (!!) //
        self.performSegueWithIdentifier("HomeSegue", sender : self)
    }
    
    // Generate a UIColor object from a Hex value
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Exit the status/check in page
    @IBAction func exitPageAction(sender: AnyObject) {
        self.view.endEditing(false)
        println("exit clicked")
    }
    
    
    // Launch the location picker (provided by Facebook SDK)
    @IBAction func pickLocationAction(sender: AnyObject) {
        var placePicker : FBPlacePickerViewController = FBPlacePickerViewController()
        placePicker.title = "Where are you studying?"
        
        //if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            //CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
                
                placePicker.locationCoordinate = CLLocationCoordinate2D(latitude: 35.305005, longitude: -120.66249399999998)
                placePicker.loadData()
                placePicker.presentModallyFromViewController(self, animated: true, handler: ({
                    (innerSender: FBViewController!, donePressed: Bool) in
                        if (!donePressed) { return }
                        var placeName = placePicker.selection.name;
                        self.locationLabel.text = placeName
                    }))
        /*}
        else {
            // User did not authenticate
        }*/
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location  = CLLocation()
        
        println("Latitude: \(manager.location.coordinate.latitude)")
        println("Longitude: \(manager.location.coordinate.longitude)")
        
        displayFBPicker()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location \(error.localizedDescription)")
    }
    
    func displayFBPicker() {
        
    }
}
