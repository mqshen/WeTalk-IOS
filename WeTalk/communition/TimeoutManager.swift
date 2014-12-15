//
//  TimeoutManager.swift
//  WeTalk
//
//  Created by GoldRatio on 12/11/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class TimeoutManager {
    
    class var sharedInstance: TimeoutManager {
        struct Singleton {
            static let instance = TimeoutManager()
        }
        return Singleton.instance
    }
    
    var commandMap: [String: TimeoutCheckable]
    let timeoutTimer: NSTimer?
    
    struct Singleton {
        static let MESSAGE_TIMEOUT_SEC = 5000
    }
    
    init() {
        commandMap = [String: TimeoutCheckable]()
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkTimeout", userInfo: nil, repeats: true)
    }
    
    func addCommand(command: TimeoutCheckable) {
        commandMap[command.seqNo] = command
    }
    
    func removeCommand(command: TimeoutCheckable) {
        commandMap[command.seqNo] = nil
    }
    
    func removeCommand(id: String) {
        commandMap[id] = nil
    }
    
    @objc func checkTimeout() {
        
        for (key, command) in commandMap {
            let timeNow = Int64(NSDate().timeIntervalSince1970 * 1000)
            let msgTimeOut = command.timestamp + Singleton.MESSAGE_TIMEOUT_SEC
            if (timeNow >= msgTimeOut) {
                println("timeout time is \(msgTimeOut),msg id is \(command.seqNo)")
                self.removeCommand(command)
                switch(command) {
                case let message as Message:
                    Session.sharedInstance.packageProcessors["3:0"]?.timeoutHandler(message)
                default:
                    println("nil")
                }
            }
        }
    }
    
}