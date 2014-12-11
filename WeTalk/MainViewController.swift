//
//  MainViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 11/26/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

let StartChatNotification = "StartChatNotification"

class MainViewController: UITabBarController, UITextFieldDelegate, UITabBarControllerDelegate{
    
    
    
    let recentViewController: RecentViewController = RecentViewController()
    let contactsViewController: ContactsViewController = ContactsViewController()
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let mainNavigateController = UINavigationController(rootViewController: recentViewController)
        self.viewControllers = [mainNavigateController, UINavigationController(rootViewController: contactsViewController)]
        self.delegate = self
        
        let messageReceiveProcessor = MessageReceiveProcessor(viewController: self)
        Session.sharedInstance.packageProcessors[messageReceiveProcessor.responseKey()] = messageReceiveProcessor
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var lastViewController: UIViewController?
    var searchController: UISearchDisplayController?
    var contactSearchController: UISearchDisplayController?
    
    //var toolView: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.selectedIndex = 0

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startChat:", name: StartChatNotification, object: nil)
//        self.delegate = self
//        chatViewController.mainViewController = self
//        
//        self.viewControllers = [chatViewController, contactsViewController]
//        
//        let frame = self.view.frame
//        
//        self.view.backgroundColor = UIColor.whiteColor()
//        
//        self.tabBar.barTintColor = UIColorFromRGB(0x22282D)
//        self.selectedIndex = 0
//        
//        let session = Session.sharedInstance
//        
//        session.socketIO = SocketIO(url: "socket.io/1/", endpoint: "testendpoint")
//        session.socketIO!.delegate = self
//        session.socketIO!.connect()
//        
//        self.hidesBottomBarWhenPushed = true
//        self.title = "聊天"
//        
//
//        self.searchController = UISearchDisplayController(searchBar: self.chatViewController.searchBar, contentsController: self)
//        
//        
//        self.navigationController?.navigationBar.translucent = false
//        
//        let chatButton = UIBarButtonItem(image: UIImage(named: "add@2x.png"),
//            style: UIBarButtonItemStyle.Plain,
//            target: self,
//            action: "showAddChat")
//        
//        self.navigationItem.rightBarButtonItem = chatButton
//        
//        self.tabBar.translucent = false
    }
    

    func startChat(note: NSNotification) {
        if let userInfo = note.userInfo? {
            if let object: AnyObject = userInfo["user"]? {
                self.selectedIndex = 0
                if let user = object as? User {
                    self.recentViewController.startChat(user.id, userType: user.userType)
                    PersistenceProcessor.sharedInstance.createChatTable(user.id)
                }
                else if let group = object as? Group {
                    self.recentViewController.startChat(group.id, userType: UserType.Room)
                    PersistenceProcessor.sharedInstance.createChatTable("\(group.id)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkLogin() -> Bool {
        let vc = ViewController()
        vc.deleage = self
        self.presentViewController(vc, animated: false, completion:nil)
        return false
    }
    
    
}