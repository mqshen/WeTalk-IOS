//
//  FriendSearchViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 12/15/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class UserSearchRequest: Serializable, TimeoutCheckable
{
    var name: String
    var seqNo: String
    var timestamp: Int64  = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    required init(json: JSON) {
        self.name = json["name"].stringValue
        self.seqNo = ""
        super.init(json: json)
    }
    
    override init() {
        self.seqNo = ""
        self.name = ""
        super.init()
    }
    
    init(name: String) {
        self.name = name
        self.seqNo = Session.sharedInstance.messageId
        super.init()
    }
    
    func packageData() -> NSString {
        return "5:5:" + self.toJsonString()
    }
    
}

class  FriendSearchViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var searchText: String?
    var users: [User]?
    
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
        
        self.title = "搜索结果"
        
        if let name = self.searchText? {
            let session = Session.sharedInstance
            let userSearch = UserSearchRequest(name: name)
            let searchProcessor = UserSearchProcessor(viewController: self)
            session.addProcessor(searchProcessor)
            session.sendMessage(userSearch)
        }
        
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
            if user.userType == UserType.User {
                cell?.setAvatar(user.avatar)
            }
            else {
                cell?.swImageView.image = UIImage(named: "room@2x.png")
            }
            cell?.textLabel?.text = user.nick
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func loadSearchResult(users: [User]) {
        self.users = users
        self.tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = self.users?[indexPath.row] {
            let vc = UserInfoViewController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}