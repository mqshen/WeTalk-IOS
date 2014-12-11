//
//  Command.swift
//  WeTalk
//
//  Created by GoldRatio on 11/30/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation


func commandResponseArrived(json: JSON) {
    if let msgId = json["seqNo"].string? {
        TimeoutManager.sharedInstance.removeCommand(msgId)
    }
}


protocol TimeoutCheckable {
    var seqNo: String {get}
    var timestamp: Int64 {get}
}
protocol Command {
    
    func responseKey() -> String
    
    func handle(json: JSON)
    
    func timeoutHandler()
}


class UserAuth : Serializable, TimeoutCheckable {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let userName: String
    let password: String
    
    init(userName: String, password: String) {
        self.userName = userName
        self.password = password
        super.init()
    }

    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    func packageData() -> NSString {
        return "1:1:" + self.toJsonString()
    }
}

class LoginProcessor: Command {
    
    func responseKey() -> String {
        return "1:0"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        NSNotificationCenter.defaultCenter().postNotificationName(LoginNotification, object: nil, userInfo: nil)
        if let user = json["user"].toObject("User") as? User {
            let session = Session.sharedInstance
            session.user = user
        }
    }
    
    func timeoutHandler() {
        
    }
}

class ContactsRefresh: Serializable,TimeoutCheckable {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    override init() {
        super.init()
    }

    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    func packageData() -> NSString {
        return "5:1:" + self.toJsonString()
    }
    
}

class MessageReceiveProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    let viewController: MainViewController
    init(viewController: MainViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "3:1"
    }
    
    func handle(json: JSON) {
        
        commandResponseArrived(json)
        
    }
    
    func timeoutHandler() {
        
    }
    
}

class ContactsProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    let viewController: ContactsViewController
    
    init(viewController: ContactsViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "5:1"
    }
    
    func handle(json: JSON) {
        let array:[JSON] = json["friends"].array!
        var friends = [User]()
        for item in array {
            if let friend = item.toObject("User") as? User {
                PersistenceProcessor.sharedInstance.addFriend(friend)
                friends.append(friend)
            }
        }
        
        Session.sharedInstance.friends = friends
        viewController.tableView.reloadData()
    }
    
    func timeoutHandler() {
        
    }
}