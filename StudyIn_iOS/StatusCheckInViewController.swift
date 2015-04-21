//
//  StatusUpdateViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit
import CoreLocation

class StatusCheckInViewController: UITableViewController {

    @IBOutlet var statusTxtView: UITextView!
    //@IBOutlet var statusTxt: UITextField!
    @IBOutlet var classTxt: UITextField!
    @IBOutlet var professorTxt: UITextField!
    @IBOutlet var privatePostSwitch: UISwitch!
    @IBOutlet var checkInBtn: UIButton!
    @IBOutlet var locationLabel: UILabel!
    
    let user = User.sharedInstance
    let parseDao : ParseDAO = ParseDAO()
    
    override func viewWillAppear(animated: Bool) {
        self.statusTxtView.becomeFirstResponder()
        //self.statusTxt.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusTxtView.delegate = self
        self.classTxt.delegate = self;
        self.professorTxt.delegate = self;
        
        statusTxtView.text = "What are you studying?"
        statusTxtView.textColor = UIColor.lightGrayColor()
        statusTxtView.selectedTextRange = statusTxtView.textRangeFromPosition(statusTxtView.beginningOfDocument, toPosition: statusTxtView.beginningOfDocument)
    }

    override func viewDidAppear(animated : Bool) {
        super.viewDidAppear(animated)
        statusTxtView.becomeFirstResponder()
    }
    
    // Event handler for post action.
    func postAction() {
        var currentTime = NSDate();
        var statusText = self.statusTxtView.text ?? "";
        var classText = self.classTxt.text ?? "";
        var professorText = self.professorTxt.text ?? "";
        
        var course = parseDao.getCourseParseObj(classText)
        var prof = parseDao.getProfessorParseObj(professorText)
        parseDao.savePostToParse(statusText, course: course, prof: prof)
        
        self.performSegueWithIdentifier("UnwindToHomeSegue", sender : self)
    }
    
    // Event handler for check-in action.
    func checkInAction () {
        var currentTime = NSDate();
        var locationLabel = self.locationLabel.text!
        
        if (locationLabel != "Name your location") {
            user.isCheckedIn = true;
            //var checkIn = UserCheckInOut(type : .CHECKIN, silentPost : isPrivateCheckIn(), location : locationLabel, timeStamp : currentTime);
            //user.userCheckInOuts.append(checkIn);
            
            var loc = parseDao.getLocationParseObj(locationLabel)
            parseDao.saveCheckInToParse(loc)
            
            self.performSegueWithIdentifier("UnwindToHomeSegue", sender : self)
        }
        else {
            showAlertViewWithMessage("Your New Check In", message : "Hey there, we ask that you please specify your location when you want to check in, thanks!")
        }
    }
    
    // Event handler for check-out action.
    func checkOutAction() {
        var currentTime = NSDate();
        var locationLabel = self.locationLabel.text!
        
        if (locationLabel != "Name your location") {
            //var checkOut = UserCheckInOut(type : .CHECKOUT, silentPost : isPrivateCheckIn(), location : locationLabel, timeStamp : currentTime);
            //user.userCheckInOuts.append(checkOut);
            
            parseDao.saveCheckOutToParse()
            user.isCheckedIn = false;
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

extension StatusCheckInViewController : UITextViewDelegate, UITextFieldDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = statusTxtView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if count(updatedText) == 0 {
            
            textView.text = "What are you studying?"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if statusTxtView.textColor == UIColor.lightGrayColor() && count(text) > 0 {
            textView.text = nil
            textView.textColor = Utils.uicolorFromHex(0x62CDFF)
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
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
        textView.inputAccessoryView = toolBar
        
        return true
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
        buttonItemImg.titleLabel?.tintColor = Utils.uicolorFromHex(0xFFFFFF)
        
        if let font = UIFont(name: "Lato", size: 15) {
            buttonItemImg.titleLabel?.font = font;
        }
        
        buttonItemImg.setTitle(textLabel, forState: .Normal)
        buttonItemImg.backgroundColor = Utils.uicolorFromHex(0x62CDFF)
        buttonItemImg.frame = CGRectMake(0, 0, (screenWidth / 2) - 20, 35)
        
        var actionSelector : Selector = Selector(actionName)
        buttonItemImg.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonItem : UIBarButtonItem = UIBarButtonItem(customView: buttonItemImg)
        
        return buttonItem
    }
}
