//
//  GroupsViewController.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 2/3/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import UIKit

class GroupCell : UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
}

class GroupsTableViewController: UITableViewController {

    var groups : [PFObject]!
    let user = User.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groups = []
        loadGroups()
        // Do any additional setup after loading the view.
    }
    
    func loadGroups() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GroupsTableViewController : UITableViewDataSource {
    
}
