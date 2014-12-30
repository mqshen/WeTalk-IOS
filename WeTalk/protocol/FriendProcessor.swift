//
//  FriendProcessor.swift
//  WeTalk
//
//  Created by GoldRatio on 12/15/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class UserSearchProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    let viewController: FriendSearchViewController
    
    init(viewController: FriendSearchViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "5:5"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        var users = [User]()
        for userJson in json["users"].array! {
            let user = User(json: userJson )
            users.append(user)
        }
        viewController.loadSearchResult(users)
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}

class FriendProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let viewController: UserInfoViewController
    
    init(viewController: UserInfoViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "5:6"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        self.viewController.addSuccess()
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}

class FriendAddProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    init() {
    }
    
    func responseKey() -> String {
        return "5:7"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        let userJson = json["user"]
        let user = User(json: userJson )
        PersistenceProcessor.sharedInstance.addRequestFriend(user, greeting: "")
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}