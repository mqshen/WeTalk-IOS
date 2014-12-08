//
//  Command.swift
//  WeTalk
//
//  Created by GoldRatio on 11/30/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

protocol Command {
    
    func responseKey() -> String
    
    func handle(json: JSON)
}


class UserAuth : Serializable {
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
        NSNotificationCenter.defaultCenter().postNotificationName(LoginNotification, object: nil, userInfo: nil)
        if let user = json["user"].toObject("User") as? User {
            let session = Session.sharedInstance
            session.user = user
        }
    }
    
}

class ContactsRefresh: Serializable {
    let seqNo: Int
    
    init(seqNo: Int) {
        self.seqNo = seqNo;
        super.init()
    }

    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    func packageData() -> NSString {
        return "5:1:" + self.toJsonString()
    }
    
}

class ContactsProcessor: Command {
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
    
}