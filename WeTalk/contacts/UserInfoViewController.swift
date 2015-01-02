//
//  UserInfoViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 12/16/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

public enum UserOperate: Int {
    case Add, ReceiveAdd, Accept, ReceiveAccept, Reject, ReceiveReject
}

class UserOperateRequest: Serializable, TimeoutCheckable
{
    var id: String
    var seqNo: String
    var greeting: String
    var operate: UserOperate = .Add
    var timestamp: Int64  = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    required init(json: JSON) {
        self.id = json["name"].stringValue
        self.seqNo = ""
        self.greeting = ""
        super.init(json: json)
    }
    
    override init() {
        self.seqNo = ""
        self.id = ""
        self.greeting = ""
        super.init()
    }
    
    init(id: String, operate: UserOperate) {
        self.id = id
        self.greeting = ""
        self.seqNo = Session.sharedInstance.messageId
        self.operate = operate
        super.init()
    }
    
    func packageData() -> NSString {
        return "5:3:" + self.toJsonString()
    }
    
    override func toDictionary() -> NSMutableDictionary {
        var modelDictionary = super.toDictionary()
        modelDictionary.setValue(operate.rawValue, forKey: "operate")
        return modelDictionary
    }
}

class UserInfoViewController: UITableViewController, FriendOperateDelegate {
    var user: User?
    
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
        
        if let user = self.user? {
            self.title = user.nick
            self.tableView.dataSource = self
            self.tableView.delegate = self
            
            let headView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 60))
            let swImageView = SWWebImageView(frame: CGRectMake(15, 10, 40, 40))
            
            if let nsUrl = NSURL(string: user.avatar)? {
                swImageView.setImage(nsUrl, placeholderImage: UIImage(named: "placeholder@2x.png")!)
            }
            
            let nickLabel = UILabel(frame: CGRectMake(60, 10, 100, 12))
            nickLabel.text = user.nick
            nickLabel.font = UIFont.systemFontOfSize(10)
            nickLabel.textColor = UIColor.lightGrayColor()
            
            headView.addSubview(swImageView)
            headView.addSubview(nickLabel)
            
            self.tableView.tableHeaderView = headView
            
            let footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 60))
            let button = UIButton(frame: CGRectMake(10, 20, self.view.frame.size.width - 20, 40))
            button.setTitle("添加到通讯录", forState:.Normal)
            //button.setBackgroundColor(UIColor.greenColor, forState:.Normal)
            footerView.addSubview(button)
            button.backgroundColor = UIColorFromRGB(0x09BE0E)
            button.addTarget(self, action:"addFriend", forControlEvents:.TouchUpInside)
            self.tableView.tableFooterView = footerView
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = Session.sharedInstance
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        cell?.textLabel?.font = UIFont.systemFontOfSize(10)
        cell?.textLabel?.textColor = UIColor.lightGrayColor()
        if indexPath.row == 0 {
            cell?.textLabel?.text = "地区\t\t \(user?.nick)"
        }
        else {
            cell?.textLabel?.text = "个人签名\t\t \(user?.nick)"
        }
        
        return cell!
    }
    
    func addFriend() {
        
        let userAdd = UserOperateRequest(id: self.user!.id, operate: .Add)
        let session = Session.sharedInstance
        //let processor = FriendOperateProcessor(viewController: self)
        //session.addProcessor(processor)
        session.sendMessage(userAdd)
    }
    
    func addSuccess() {
        let view = UIAlertView(title: "提示", message: "添加成功", delegate: nil, cancelButtonTitle:"确定")
        view.show()
    }
    
    func friendAddSuccess(user: User, greeting: String) {
        let view = UIAlertView(title: "提示", message: "添加成功", delegate: nil, cancelButtonTitle:"确定")
        view.show()
    }
    
    func friendReceiveAddSuccess(user: User, greeting: String) {
        
    }
    
    func friendAcceptSuccess(user: User, greeting: String) {
        
    }
    
    func friendReceiveAcceptSuccess(user: User, greeting: String) {
        
    }
}