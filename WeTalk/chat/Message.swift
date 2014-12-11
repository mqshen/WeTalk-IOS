//
//  Message.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

enum MessageStatus: Int {
    case Send, Receive
}

enum MessageType: Int {
    case Text, Image, Audio, Video
}

class Message: Serializable, TimeoutCheckable
{
    let seqNo: String
    let from: String
    let to: String
    let messageType: MessageType
    let content: String
    let attach: String?
    let timestamp: Int64 = 0
    let status: MessageStatus = .Receive
    
    required init(json: JSON) {
        self.seqNo = json["seqNo"].stringValue
        self.from = json["from"].stringValue
        self.to = json["to"].stringValue
        self.content = json["content"].stringValue
        if let attach = json["attach"].string? {
            self.attach = attach//.stringByReplacingOccurrencesOfString("\r\n", withString: "\\r\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        self.timestamp = json["timestamp"].int64Value
        self.status = MessageStatus(rawValue: json["status"].intValue)!
        self.messageType = MessageType(rawValue: json["messageType"].intValue)!
        super.init(json: json)
    }
    
    override init() {
        self.seqNo = ""
        self.from = ""
        self.to = ""
        self.content = ""
        self.timestamp = 0
        self.messageType = .Text
        super.init()
    }
    
    init(seqNo: String, from: String, to: String, content: String, attach: String?, timestamp: Int64, messageType: MessageType = .Text, status: MessageStatus = .Receive) {
        self.seqNo = seqNo
        self.from = from
        self.to = to
        self.content = content
        self.attach = attach
        self.timestamp = timestamp
        self.status = status
        self.messageType = messageType
        super.init()
    }
    
    
    
//    func toJson() -> String {
//        return "{\"fromUserName\": \"\(fromUserName)\", \"toUserName\": \"\(toUserName)\",\"type\": \(type),\"content\": \"\(content)\",\"clientMsgId\": \(clientMsgId), \"timestamp\": \(createTime)}"
//    }
//    
    
   // func toDictionary() ->
    override func toDictionary() -> NSMutableDictionary {
        var modelDictionary = super.toDictionary()
        if let attach = self.attach? {
            modelDictionary.setValue(attach, forKey: "attach")
        }
        return modelDictionary
    }
    
    func packageData() -> NSString {
        return "3:1:" + self.toJsonString()
    }
    
    lazy var image: UIImage? = {
        if let originalString = self.attach? {
            if let imageData = NSData(base64EncodedString:originalString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)? {
                return UIImage(data:imageData)
            }
        }
        return nil
    }()
}