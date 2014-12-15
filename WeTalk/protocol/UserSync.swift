//
//  UserSync.swift
//  WeTalk
//
//  Created by GoldRatio on 12/13/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class UserSync: Serializable, TimeoutCheckable {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let syncKey: Int64
    let userId: Int64
    
    init(syncKey: Int64, userId: Int64) {
        self.syncKey = syncKey
        self.userId = userId
        super.init()
    }
    
    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }
    
    func packageData() -> NSString {
        return "1:2:" + self.toJsonString()
    }
}

class UserSyncProcessor: Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    init() {
    }
    
    func responseKey() -> String {
        return "1:2"
    }
    
    func handle(json: JSON) {
        if let syncKey = json["syncKey"].int64? {
            PersistenceProcessor.sharedInstance.updateSyncKey(syncKey)
        }
        if let message = json["message"].string? {
            Session.sharedInstance.didReceiveMessage(message)
        }
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}