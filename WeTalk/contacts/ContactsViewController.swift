//
//  ContactsViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ContactsViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate
{
    var searchBar: UISearchBar?
    
    override init(style: UITableViewStyle = UITableViewStyle.Grouped) {
        super.init(style: style)
        self.tabBarItem = UITabBarItem(title: "通讯录",
            image:  UIImage(named: "tabbar_contacts@2x.png"),
            selectedImage: UIImage(named: "tabbar_contactsHL@2x.png"))
        
        self.refreshFriends()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "通讯录",
            image:  UIImage(named: "tabbar_contacts@2x.png"),
            selectedImage: UIImage(named: "tabbar_contactsHL@2x.png"))
    }
    
    func refreshFriends() {
        let session = Session.sharedInstance
        
        let contactsProcessor = ContactsProcessor(viewController: self)
        session.packageProcessors[contactsProcessor.responseKey()] = contactsProcessor
        
        let listGroupProcessor = ListGroupProcessor(viewController: self)
        session.packageProcessors[listGroupProcessor.responseKey()] = listGroupProcessor
        
        session.refreshFriends()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "通讯录"
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        
        self.navigationController?.navigationBar.translucent = false
      
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar = UISearchBar()
        self.searchBar?.sizeToFit()
        self.tableView.tableHeaderView = self.searchBar
    }
    
    func receiveContacts(contacts: Array<User>) {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let session = Session.sharedInstance
        if session.groups.count > 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let session = Session.sharedInstance
        if session.groups.count > 0 && section == 0 {
            return session.groups.count
            
        }
        return session.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = Session.sharedInstance
        var cell: ContactViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? ContactViewCell
        if (cell == nil) {
            cell = ContactViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if session.groups.count > 0 && indexPath.section == 0 {
            let group = session.groups[indexPath.row]
            cell?.swImageView.image = UIImage(named: "room@2x.png")
            cell?.textLabel?.text = group.name
        }
        else {
            let user = session.friends[indexPath.row]
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let session = Session.sharedInstance
        if session.groups.count > 0 && indexPath.section == 0 {
            var user = session.groups[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName(StartChatNotification, object: nil, userInfo: ["user":user])
        }
        else {
            var user = session.friends[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName(StartChatNotification, object: nil, userInfo: ["user":user])
        }
    }
}