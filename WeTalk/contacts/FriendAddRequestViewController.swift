//
//  FriendAddRequestViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 12/30/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class FriendOperateResponse: Serializable, TimeoutCheckable
{
    var user: User
    var operate: UserOperate
    var greeting: String
    var seqNo: String
    var timestamp: Int64  = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    required init(json: JSON) {
        self.user = User(json: json["user"])
        self.seqNo = json["seqNo"].stringValue
        self.operate = UserOperate(rawValue:json["operate"].intValue)!
        self.greeting = json["greeting"].stringValue
        super.init(json: json)
    }

  
    
    func packageData() -> NSString {
        return "5:3:" + self.toJsonString()
    }
}

class FriendAddRequestViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, TableButtonDelegate, FriendOperateDelegate {
    var users: [(User, String, Int)]?
    
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
        var cell: ButtonTableCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ButtonTableCell
        if (cell == nil) {
            cell = ButtonTableCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            cell?.delegate = self
        }
        
        if let user = self.users?[indexPath.row] {
            cell?.setAvatar(user.0.avatar)
            cell?.textLabel?.text = user.0.nick
            cell?.setAccept(user.2)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func doAccept(cell: UITableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell)? {
            if let user = self.users?[indexPath.row] {
                let request = UserOperateRequest(id: user.0.id, operate: .Accept)
                let session = Session.sharedInstance
                session.sendMessage(request)
            }
            
        }
    }
    
    func doReject(cell: UITableViewCell) {
        
    }
    
    func friendAddSuccess(user: User) {
        for (index, var u) in enumerate(self.users!) {
            if u.0.id == user.id {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ButtonTableCell {
                    cell.setAccept(1)
                }
                u.2 = 1
            }
            self.users?[index] = u
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let session = Session.sharedInstance
        session.setFriendOperateViewController(self)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let session = Session.sharedInstance
        session.setFriendOperateViewController(nil)
    }
    
    
    func friendAddSuccess(user: User, greeting: String) {
    }
    
    func friendReceiveAddSuccess(user: User, greeting: String) {
    }
    
    func friendAcceptSuccess(user: User, greeting: String) {
        friendAddSuccess(user)
    }
    
    func friendReceiveAcceptSuccess(user: User, greeting: String) {
        
    }
}