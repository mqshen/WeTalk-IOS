//
//  FriendAddRequestViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 12/30/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class FriendAddRequestViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var users: [(User, String)]?
    
    override init(style: UITableViewStyle = UITableViewStyle.Plain) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "新朋友"
        
        self.users = PersistenceProcessor.sharedInstance.getRequestFriend()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let users = self.users? {
            return users.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = Session.sharedInstance
        var cell: ContactViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ContactViewCell
        if (cell == nil) {
            cell = ContactViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        
        if let user = self.users?[indexPath.row] {
            cell?.setAvatar(user.0.avatar)
            cell?.textLabel?.text = user.0.nick
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
}