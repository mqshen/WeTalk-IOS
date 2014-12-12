//
//  RecentViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class RecentViewController: UITableViewController
{
    
    var searchBar: UISearchBar?
    
    var chats:[(String, UserType, Message?)] = PersistenceProcessor.sharedInstance.getRecentChats()
    var currentUserId: String? = nil
    var messageViewController: MessageViewController?
    var toolView: PopupView?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "聊天",
            image:  UIImage(named: "tabbar_mainframe@2x.png"),
            selectedImage: UIImage(named: "tabbar_mainframeHL@2x.png"))
        
        let messageProcessor = MessageProcessor(viewController: self)
        Session.sharedInstance.packageProcessors[messageProcessor.responseKey()] = messageProcessor
    }
    
    override init(style: UITableViewStyle = UITableViewStyle.Plain) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(title: "聊天",
            image:  UIImage(named: "tabbar_mainframe@2x.png"),
            selectedImage: UIImage(named: "tabbar_mainframeHL@2x.png"))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "聊天"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar = UISearchBar()
        self.searchBar?.sizeToFit()
        self.tableView.tableHeaderView = self.searchBar
        
        
        let chatButton = UIBarButtonItem(image: UIImage(named: "add@2x.png"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "showAddChat")
        
        self.navigationItem.rightBarButtonItem = chatButton
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.translucent = false
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ChatViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ChatViewCell
        if (cell == nil) {
            cell = ChatViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        let item = self.chats[indexPath.row]
        //let id = self.chats[indexPath.row].0
        if let user = Session.sharedInstance.getUserById(item.0, userType: item.1) {
            cell?.textLabel?.text = user.nick
            cell?.setAvatar(user.avatar)
        }
        
        if let message = self.chats[indexPath.row].2? {
            let time = NSDate(timeIntervalSince1970: Double(message.timestamp / 1000))
            cell?.timeLabel.text = time.detailDateTimeUntilNow()
            if message.messageType == .Text {
                cell?.recentLabel.text = message.content
            }
            else if message.messageType == .Image {
                cell?.recentLabel.text = "[图片]"
            }
            else if message.messageType == .Audio {
                cell?.recentLabel.text = "[语音]"
            }
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func startChat(id: String, userType: UserType) {
        for chat in chats {
            if id == chat.0 && userType == chat.1 {
                self.pushViewController(id, userType: userType)
                return
            }
        }
        let element: (String, UserType, Message?) = (id, userType, nil)
        chats.append(element)
        self.tableView.reloadData()
        self.pushViewController(id, userType: userType)
    }
    
    func pushViewController(id: String, userType: UserType) {
        if let user = Session.sharedInstance.getUserById(id, userType: userType)? {
            let messageViewController = MessageViewController()
            messageViewController.hidesBottomBarWhenPushed = true
            messageViewController.user = user
            self.currentUserId = id
            self.navigationController?.pushViewController(messageViewController, animated: true)
            self.messageViewController = messageViewController
        }
    }

        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let userName = self.chats[indexPath.row].0
        let userType = self.chats[indexPath.row].1
        self.pushViewController(userName, userType: userType)
    }
    
    func receiveMessage(message: Message) {
        PersistenceProcessor.sharedInstance.addMessage(message)
        if let currentUserId = self.currentUserId? {
            if(message.from == currentUserId) {
                self.messageViewController?.receiveMessage(message)
            }
        
        }
    }
    
    func timeout(message: Message) {
        PersistenceProcessor.sharedInstance.setMessageTimeout(message)
        if let currentUserId = self.currentUserId? {
            if(message.to == currentUserId) {
                self.messageViewController?.timeout(message)
            }
            
        }
    }
    
    func showAddChat() {
        let imageButton = ImageButton(frame: CGRectMake(5, 5, 70, 40),
            image: UIImage(named: "tabbar_mainframe.png")!, text: "发起群聊", textColor:  UIColor.whiteColor(), vertical: false)
        imageButton.textLabel.font = UIFont.systemFontOfSize(9)
        imageButton.addTarget(self, action: "doAddGroupChat", forControlEvents:UIControlEvents.ValueChanged)
        self.toolView = PopupView(frame: CGRectMake(260, 0, 80, 150))
        self.toolView?.addSubview(imageButton)
        self.toolView?.popup()
    }
    
    func doAddGroupChat() {
        self.toolView?.hide()
        
        let vc = UserSelectViewController()
        let navVC = UINavigationController(rootViewController: vc)
        self.presentViewController(navVC, animated: true, completion: nil)
    }
}