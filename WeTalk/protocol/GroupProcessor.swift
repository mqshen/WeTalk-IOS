//
//  GroupProcessor.swift
//  WeTalk
//
//  Created by GoldRatio on 12/10/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class ListGroup: Serializable, TimeoutCheckable {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    func packageData() -> NSString {
        return "5:5:" + self.toJsonString()
    }
    
}


class ListGroupProcessor: Command {
    let viewController: ContactsViewController
    
    init(viewController: ContactsViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "5:5"
    }
    
    func handle(json: JSON) {
        let array:[JSON] = json["groups"].array!
        var groups = [Group]()
        for item in array {
            let group = Group(json: item)
            PersistenceProcessor.sharedInstance.addGroup(group)
            groups.append(group)
        }
        Session.sharedInstance.groups = groups
        viewController.tableView.reloadData()
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}

class GroupProcessor: Command {
    let viewController: RecentViewController
    
    init(viewController: RecentViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "5:6"
    }
    
    func handle(json: JSON) {
        let group = Group(json: json)
        let session = Session.sharedInstance
        session.groups.append(group)
        PersistenceProcessor.sharedInstance.addGroup(group)
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}
