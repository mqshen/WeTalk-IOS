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

protocol FriendOperateDelegate: class {
    func friendAddSuccess(user: User, greeting: String)
    func friendReceiveAddSuccess(user: User, greeting: String)
    func friendAcceptSuccess(user: User, greeting: String)
    func friendReceiveAcceptSuccess(user: User, greeting: String)
}

class FriendOperateProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    weak var delegate: FriendOperateDelegate?
    
    init() {
    }
    
    func responseKey() -> String {
        return "5:3"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        let response = FriendOperateResponse(json: json)
        if response.operate == .ReceiveAdd {
            PersistenceProcessor.sharedInstance.addRequestFriend(response.user, greeting: response.greeting)
        }
        else if response.operate == .Accept {
            
            PersistenceProcessor.sharedInstance.updateRequestFriend(response.user, accept: 1)
            PersistenceProcessor.sharedInstance.addFriend(response.user)
            if let delegate = self.delegate? {
                delegate.friendAcceptSuccess(response.user, greeting: response.greeting)
            }
        }
        else if response.operate == .ReceiveAccept {
            PersistenceProcessor.sharedInstance.addFriend(response.user)
        }
        else {
            if let delegate = self.delegate? {
                delegate.friendAddSuccess(response.user, greeting: response.greeting)
            }
            
        }
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}

//class FriendAddProcessor: Command {
//    var seqNo: String = Session.sharedInstance.messageId
//    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
//    
//    init() {
//    }
//    
//    func responseKey() -> String {
//        return "5:7"
//    }
//    
//    func handle(json: JSON) {
//        commandResponseArrived(json)
//        let userJson = json["user"]
//        let user = User(json: userJson )
//        PersistenceProcessor.sharedInstance.addRequestFriend(user, greeting: "")
//    }
//    
//    func timeoutHandler(timeout: TimeoutCheckable) {
//        
//    }
//}
//
//class FriendAddResponseProcessor: Command {
//    
//    var seqNo: String = Session.sharedInstance.messageId
//    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
//    let viewController: FriendAddRequestViewController
//    
//    init(viewController: FriendAddRequestViewController) {
//        self.viewController = viewController
//    }
//    
//    func responseKey() -> String {
//        return "5:8"
//    }
//    
//    func handle(json: JSON) {
//        commandResponseArrived(json)
//        let userJson = json["user"]
//        let user = User(json: userJson)
//        viewController.friendAddSuccess(user)
//        PersistenceProcessor.sharedInstance.addFriend(user)
//    }
//    
//    func timeoutHandler(timeout: TimeoutCheckable) {
//        
//    }
//}