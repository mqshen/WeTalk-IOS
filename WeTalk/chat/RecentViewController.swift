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
    
    var chats:[(String, Message?)] = PersistenceProcessor.sharedInstance.getRecentChats()
    var currentUserId: String? = nil
    var messageViewController: MessageViewController?
    
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
        let id = self.chats[indexPath.row].0
        if let user = Session.sharedInstance.getUserById(id) {
            cell?.textLabel?.text = user.nick
        }
        
        if let message = self.chats[indexPath.row].1? {
            let time = NSDate(timeIntervalSince1970: Double(message.timestamp / 1000))
            cell?.timeLabel.text = time.detailDateTimeUntilNow()
            cell?.recentLabel.text = message.content
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func startChat(id: String) {
        for chat in chats {
            if id == chat.0 {
                self.pushViewController(id)
                return
            }
        }
        let element: (String, Message?) = (id, nil)
        chats.append(element)
        self.tableView.reloadData()
        self.pushViewController(id)
    }
    
    func pushViewController(id: String) {
        if let user = Session.sharedInstance.getUserById(id)? {
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
        self.pushViewController(userName)
    }
    
    func receiveMessage(message: Message) {
        PersistenceProcessor.sharedInstance.addMessage(message)
        if let currentUserId = self.currentUserId? {
            if(message.from == currentUserId) {
                self.messageViewController?.receiveMessage(message)
            }
        
        }
    }
}