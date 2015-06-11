//
//  AddGroup.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 5/6/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

let SEARCH_VIEW_INDEX = 0
let CREATE_VIEW_INDEX = 1

// Custom UITableViewCell representing the table view cell result of searching for a group.
class SearchGroupCell : UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
}

class SearchView : UIView, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var groups : [PFObject]!
    var filteredGroups : [PFObject]!
    var selectedGroups : [PFObject]?
    var searchActive : Bool = false
    var doneItem : UIBarButtonItem!

    func loadSearchView(viewNavItem: UIBarButtonItem) {
        self.doneItem = viewNavItem
        self.doneItem.enabled = false
        
        self.groups = []
        self.filteredGroups = []
        self.selectedGroups = []
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchBar.delegate = self
        loadAllGroups()
        searchBar.resignFirstResponder()
    }
    
    func loadAllGroups() {
        var query = PFQuery(className: "Group")
        
        query.findObjectsInBackgroundWithBlock {
            [unowned self] (objects, error) -> Void in
            if error == nil {
                self.groups!.removeAll(keepCapacity: true)
                for object in objects {
                    self.groups!.append(object as! PFObject)
                }
                self.searchTableView.reloadData()
            }
            else {
                println(error)
            }
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredGroups = groups.filter({ (obj) -> Bool in
            let tmp: NSString = obj["name"] as! String
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        if(filteredGroups.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.searchTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as! SearchGroupCell
        
        var group : PFObject!
        if (searchActive) {
            group = filteredGroups[indexPath.row]
        }
        else {
            group = groups[indexPath.row]
        }
        
        cell.accessoryType = isGroupSelected(group) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        cell.groupName.text = group["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups != nil {
            if (searchActive) {
                return filteredGroups.count
            }
            return groups.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if (cell.accessoryType == UITableViewCellAccessoryType.None)
        {
            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            self.selectedGroups?.append(groups[indexPath.row])
            self.doneItem.enabled = true
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None

            if let index = find(selectedGroups!, groups[indexPath.row]) {
                selectedGroups?.removeAtIndex(index)
                
                if selectedGroups?.count == 0 {
                    self.doneItem.enabled = false // disable done btn if no groups are selected
                }
            } else {
                println("error with removing element")
            }
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

    }
    
    func isGroupSelected(group : PFObject) -> Bool {
        if find(selectedGroups!, group) != nil {
            return true
        }
        return false
    }
}

// TableViewController representing the "Create a Group" View.
class CreateGroupTableView : UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupDescription: UITextView!
    @IBOutlet weak var groupImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var doneItem : UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        self.groupName.addTarget(self, action: "groupNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.groupDescription.delegate = self
    }
    

    
    override func viewDidLoad() {
        self.doneItem.enabled = false
        super.viewDidLoad()
    }
    
    func groupNameTextFieldDidChange(textField: UITextField) {
        self.groupName.becomeFirstResponder()

        if doneItem != nil {
            if count(textField.text) > 0 {
                self.doneItem.enabled = true
            }
            else {
                self.doneItem.enabled = false
            }
        }
    }
    
    @IBAction func selectImageAction(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            println("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!,
        editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
        groupImage.image = image

    }
}

class CreateView : UIView, UITableViewDelegate  {
    var createSubView : CreateGroupTableView?
}

class AddGroup: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var createView: CreateView!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    
    var user = User.sharedInstance
    var groups : [PFObject]!

    override func viewWillAppear(animated: Bool) {
        self.segmentedControl.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneItem.enabled = false
        searchView.loadSearchView(self.doneItem)
    }
    
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case SEARCH_VIEW_INDEX :
            createView.createSubView?.groupName.resignFirstResponder()

            createView.hidden = true
            searchView.hidden = false
        case CREATE_VIEW_INDEX:
            searchView.searchBar.resignFirstResponder()

            createView.hidden = false
            searchView.hidden = true
        default:
            break
        }
    }
    
    // Save the selected groups resulting from a search.
    func saveGroupFromSearch() {
        let selectedGroups = searchView.selectedGroups
        
        if selectedGroups != nil && selectedGroups?.count != 0 {
            var groupsRelation = user.parseUserObject.relationForKey("groups")
            for group in selectedGroups! {
                groupsRelation.addObject(group)
            }
            user.parseUserObject.saveInBackground()
            performSegueWithIdentifier("unwindToGroupsTable", sender: self)
        }
        else {
            // Display alert: no group selected
            Utils.showAlertViewWithMessage(self, title: "No Group Selected", message: "Please select a group before proceeding.")
        }
    }
    
    // Save the newly created group.
    func saveGroupFromCreate() {
        let createTableView = self.createView.createSubView
        
        let groupName = createTableView?.groupName.text
        let groupDescription = createTableView?.groupDescription.text ?? ""
        let groupImg = createTableView?.groupImage!
        
        Utils.saveGroupToParse(groupName!, description: groupDescription, image: groupImg!)
        performSegueWithIdentifier("unwindToGroupsTable", sender: self)
    }
    
    @IBAction func saveGroup(sender: AnyObject) {
        let segmentNdx = self.segmentedControl.selectedSegmentIndex
        
        if segmentNdx == SEARCH_VIEW_INDEX {
            saveGroupFromSearch()
        }
        else if (segmentNdx == CREATE_VIEW_INDEX) {
            saveGroupFromCreate()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedCreateTableSegue" {
            createView.createSubView = segue.destinationViewController as? CreateGroupTableView
            createView.createSubView!.doneItem = self.doneItem
        }
        if segue.identifier == "unwindToGroupsTable" {
            var destinationController = segue.destinationViewController as! GroupsTableViewController
            destinationController.reloadTable()
        }
        
    }

    func cancelAction(sender: UIBarButtonItem) {

    }
    
}