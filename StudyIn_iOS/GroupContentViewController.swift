
import UIKit

class GroupMemberCell : PFTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbPhoto: FBProfilePictureView!
    
    func addUserPhoto(fbID : String) {
        fbPhoto.profileID = fbID
        
        self.fbPhoto.layer.cornerRadius = self.fbPhoto.frame.size.width / 2
        self.fbPhoto.clipsToBounds = true
        
        self.fbPhoto.layer.borderWidth = 1.0
        
        var myColor : UIColor = Utils.uicolorFromHex(0x62CDFF)
        self.fbPhoto.layer.borderColor = myColor.CGColor
    }
}

class GroupContentTableViewController : PFQueryTableViewController {
    let CONTENT_SECTION = 0
    
    let FEED_INDEX = 0
    let MEMBERS_INDEX = 1
    let STATS_INDEX = 2
    
    @IBOutlet var groupTable: UITableView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet weak var groupDescription: UITextView!
    @IBOutlet weak var profileView: UIView!
    
    var group : PFObject?
    var members : [PFObject]?
    
    var viewController: GroupContentViewController!
    var contentToDisplay : contentTypes = .Feed
    
    override func viewDidLoad() {
        self.tableView.estimatedRowHeight = 140.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        super.viewDidLoad()
        //loadMembers()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "Group"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 50
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        var usersRelation = group!.relationForKey("users") as PFRelation
        var usersQuery = usersRelation.query()
        
        switch contentToDisplay {
            case .Feed:
                var feedItemQuery = PFQuery(className: "FeedItem")
                
                feedItemQuery.includeKey("user")
                feedItemQuery.includeKey("checkOut")
                feedItemQuery.includeKey("checkOut.location")
                feedItemQuery.includeKey("checkIn")
                feedItemQuery.includeKey("checkIn.location")
                feedItemQuery.includeKey("statusUpdate")
                feedItemQuery.includeKey("statusUpdate.course")
                feedItemQuery.includeKey("statusUpdate.professor")
                
                feedItemQuery.whereKey("user", matchesQuery: usersQuery)
                feedItemQuery.orderByDescending("createdAt")
                

                return feedItemQuery
        
            case .Members:
                return usersQuery
            case .Statistics:
                return usersQuery
            default:
                return usersQuery
        }
        
    }
    
    
    func getUserInfo(myUser: PFObject) -> FeedUser {
        var myFeedUser : FeedUser = FeedUser()
        var photo = ""
        
        myFeedUser.facebookID = myUser["facebookID"] as! String
        myFeedUser.name = myUser["name"] as! String
        
        return myFeedUser
    }
    
    func makeStatusCell(object: PFObject, status: PFObject?, tableVIew: UITableView!) -> PFTableViewCell {
        // Create a status update cell.
        var feedUser = FeedUser()
        let statusObj = status!
        
        feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
        var statusText = statusObj.valueForKey("statusText") as! String
        
        var courseText = ""
        if let course = statusObj.valueForKey("course") as? PFObject {
            courseText = course.valueForKey("courseName") as! String
        }
        
        var profText = ""
        if let prof = statusObj.valueForKey("professor") as? PFObject {
            profText = prof.valueForKey("professorName") as! String
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
        cell.setUpCell(feedUser.name, statusText: statusText, course: courseText, professor: profText, photoURL: feedUser.facebookID, time: statusObj.createdAt);
        return cell;
    }
    
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        switch contentToDisplay {
            case .Feed:
                self.tableView.estimatedRowHeight = 60.0;
                self.tableView.rowHeight = UITableViewAutomaticDimension
                
                var status = object.valueForKey("statusUpdate") as? PFObject
                var checkin = object.valueForKey("checkIn") as? PFObject
                var checkout = object.valueForKey("checkOut") as? PFObject
                var feedUser = FeedUser()
                
                if status != nil {
                    // Create a status update cell.
                    let statusObj = status!
                    feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
                    var statusText = statusObj.valueForKey("statusText") as! String
                    
                    var courseText = ""
                    if let course = statusObj.valueForKey("course") as? PFObject {
                        courseText = course.valueForKey("courseName") as! String
                    }
                    
                    var profText = ""
                    if let prof = statusObj.valueForKey("professor") as? PFObject {
                        profText = prof.valueForKey("professorName") as! String
                    }
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as! UserPostCell
                    cell.setUpCell(feedUser.name, statusText: statusText, course: courseText, professor: profText, photoURL: feedUser.facebookID, time: statusObj.createdAt);
                    return cell;
                }
                else if checkin != nil {
                    // Create a check-in cell.
                    let checkInObj = checkin!
                    feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
                    var locText = "location test"
                    if let location = checkInObj.valueForKey("location") as? PFObject {
                        locText = location.valueForKey("name") as! String
                    }
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
                    cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKIN, location: locText, photoURL: feedUser.facebookID, time: checkInObj.createdAt)
                    
                    return cell;
                }
                else if checkout != nil {
                    let checkOutObj = checkout!
                    feedUser = getUserInfo(object.valueForKey("user") as! PFObject)
                    // Create a check-out cell.
                    let cell = tableView.dequeueReusableCellWithIdentifier("checkInOutCell") as! UserCheckInOutCell
                    cell.setUpCell(feedUser.name, type: FeedObjectType.CHECKOUT, location: "", photoURL : feedUser.facebookID, time: checkOutObj.createdAt)
                    
                    return cell;
                }
            case .Members:
                let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! GroupMemberCell
                let name = object["name"] as! String
                let fbId = object["facebookID"] as! String
                
                cell.nameLabel.text = name
                cell.addUserPhoto(fbId)
                
                self.tableView.rowHeight = 60
                return cell
            default:
                println("default")
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! PFTableViewCell
        return cell
    
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        
        if (indexPath.row < self.objects!.count) {
            obj = self.objects![indexPath.row] as? PFObject
        }
        
        return obj
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        viewController.scrollViewDidScroll(scrollView)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count

    }
    
}

class GroupContentView : UIView {
    var groupContentView : GroupContentTableViewController!
}

enum contentTypes {
    case Feed, Members, Statistics
}

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label

class GroupContentViewController: UIViewController, UIScrollViewDelegate {
    var group : PFObject?
    
    @IBOutlet weak var groupContentContainer: GroupContentView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var segmentedView : UIView!
    
    var headerBlurImageView:UIImageView!
    var headerImageView:UIImageView!
    
    var backButtonView : UIView!
    var backButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupContentContainer.groupContentView.groupTable.contentInset = UIEdgeInsetsMake(header.frame.height, 0, 0, 0)
    }
    
    func fetchGroupDetails() {
        group!.fetchIfNeededInBackgroundWithBlock {
            [unowned self] (groupObj, error) -> Void in
            if error == nil {
                var name = self.group!["name"] as! String
                self.groupContentContainer.groupContentView.groupName.text = name
                self.groupContentContainer.groupContentView.groupName.font = UIFont(name: "Lato", size: 17)

                self.headerLabel.text = name
                if let  description = self.group!["description"] as? String {
                    self.groupContentContainer.groupContentView.groupDescription.text = description
                    self.groupContentContainer.groupContentView.groupDescription.textColor = Utils.uicolorFromHex(0x6F7179)
                    self.groupContentContainer.groupContentView.groupDescription.font = UIFont(name: "Lato", size: 13)
                    
                } else {
                    self.groupContentContainer.groupContentView.groupDescription.removeFromSuperview()
                }
                if let imageFile = self.group?.objectForKey("image") as? PFFile {
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            self.headerImageView?.image = UIImage(data: imageData)
                            self.headerBlurImageView?.image = UIImage(data: imageData)?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
                        }
                    }
                }
            }
        }
        
        
        //groupContentContainer.groupContentView.groupName.text = name
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Header - Image
        let backImageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        let backImage = UIImage(named: "arrow-back")
        backImageView.image = backImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backImageView.tintColor = UIColor.whiteColor()
        
        backButton = UIButton(frame: CGRectMake(6, 18, 30, 30))
        backButton.addTarget(self, action: "backButtonPressed:", forControlEvents: .TouchUpInside)
        backButton.addSubview(backImageView)
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = UIImage(named: "desk-supplies")
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = UIImage(named: "desk-supplies")?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
        
        self.view.insertSubview(backButton, aboveSubview: header)
        
        fetchGroupDetails()

    }
    
    func backButtonPressed(sender:UIButton!)
    {
        performSegueWithIdentifier("unwindToGroupsTable", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embededGroupTable" {
            groupContentContainer.groupContentView = segue.destinationViewController as? GroupContentTableViewController
            groupContentContainer.groupContentView.group = self.group
            groupContentContainer.groupContentView.viewController = sender as! GroupContentViewController
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y + header.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            
            // Hide views if scrolled super fast
            header.layer.zPosition = 0
            headerLabel.hidden = true
            
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            headerLabel.hidden = false
            var alignToNameLabel = -offset + groupContentContainer.groupContentView.groupName.frame.origin.y + header.frame.height + offset_HeaderStop
            
            headerLabel.frame.origin = CGPointMake(headerLabel.frame.origin.x, max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
            
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / groupContentContainer.groupContentView.groupName.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((groupContentContainer.groupContentView.groupName.bounds.height * (1.0 + avatarScaleFactor)) - groupContentContainer.groupContentView.groupName.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if groupContentContainer.groupContentView.groupName.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
                
            } else {
                if groupContentContainer.groupContentView.groupName.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                    backButton.layer.zPosition = 2
                    //self.backButton.removeFromSuperview()
                    //self.view.addSubview(backButton)
                }
                
            }
        }
        // Apply Transformations
        header.layer.transform = headerTransform
        groupContentContainer.groupContentView.groupName.layer.transform = avatarTransform
        
        // Segment control
        
        var segmentViewOffset = groupContentContainer.groupContentView.profileView.frame.height - segmentedView.frame.height - offset
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
        segmentedView.layer.transform = segmentTransform
        
        
        // Set scroll view insets just underneath the segment control
        groupContentContainer.groupContentView.groupTable.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
    
    @IBAction func selectContentType(sender: UISegmentedControl) {
        
        // crap code I know
        if sender.selectedSegmentIndex == 0 {
            groupContentContainer.groupContentView.contentToDisplay = .Feed
        }
        else if sender.selectedSegmentIndex == 1 {
            groupContentContainer.groupContentView.contentToDisplay = .Members
        }
        else {
            groupContentContainer.groupContentView.contentToDisplay = .Statistics
        }
        
        groupContentContainer.groupContentView.loadObjects()
    }

}