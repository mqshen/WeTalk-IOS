//
//  HeartbeatProcessor.swift
//  WeTalk
//
//  Created by GoldRatio on 1/3/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation

class HeartbeatProcessor : Command {
    var seqNo: String = Session.sharedInstance.messageId
    var timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    
    init() {
    }
    
    func responseKey() -> String {
        return "2:2"
    }
    
    func handle(json: JSON) {
        let session = Session.sharedInstance
        session.sendString("2:2:\r\n")
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        
    }
}