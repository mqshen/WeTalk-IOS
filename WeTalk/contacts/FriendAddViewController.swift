//
//  FriendAddViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 12/15/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class FriendAddViewController:  UITableViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate
{
    var searchBar: UISearchBar?
    var searchController: UISearchDisplayController?
    
    override init(style: UITableViewStyle = UITableViewStyle.Grouped) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func refreshFriends() {
        let session = Session.sharedInstance
        
        session.refreshFriends()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "添加朋友"
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.navigationController?.navigationBar.translucent = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar = UISearchBar()
        self.searchBar?.delegate = self
        //self.searchBar?.sizeToFit()
        self.tableView.tableHeaderView = self.searchBar
        
        //self.view.addSubview(self.searchBar!)
        self.searchBar?.hidden = true
        
        
        self.searchController = UISearchDisplayController(searchBar:self.searchBar, contentsController:self)
    }
    
    func receiveContacts(contacts: Array<User>) {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = Session.sharedInstance
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier( "neighborCell" ) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "neighborCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        cell?.imageView?.image = UIImage(named: "add_friend_searchicon.png")
        cell?.textLabel?.text = "好友昵称"
        cell?.textLabel?.font = UIFont.systemFontOfSize(10)
        cell?.textLabel?.textColor = UIColor.lightGrayColor()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchBar?.hidden = false
        self.searchBar?.becomeFirstResponder()
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: NSInteger) -> UIView {
//        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
//        label.font = UIFont.systemFontOfSize(10)
//        let session = Session.sharedInstance
//        if session.groups.count > 0 && section == 0 {
//            label.text = "    群聊"
//        }
//        else {
//            label.text = "    好友"
//        }
//        return label
//    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection: NSInteger) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection: NSInteger) -> CGFloat {
        return CGFloat.min
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let vc = FriendSearchViewController()
        vc.searchText = self.searchBar?.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
    