//
//  MessageProcessor.swift
//  WeTalk
//
//  Created by GoldRatio on 12/2/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class MessageProcessor: Command {
    let viewController: RecentViewController
    
    init(viewController: RecentViewController) {
        self.viewController = viewController
    }
    
    func responseKey() -> String {
        return "3:0"
    }
    
    func handle(json: JSON) {
        commandResponseArrived(json)
        let m = json.toObject("Message")
        if let message = m as? Message {
            viewController.receiveMessage(message)
        }
    }
    
    func timeoutHandler(timeout: TimeoutCheckable) {
        if let message = timeout as? Message {
            self.viewController.timeout(message)
        }
    }
}