//
//  PersistenceProcessor.swift
//  Campfire
//
//  Created by GoldRatio on 9/3/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class PersistenceProcessor
{
    
    class var sharedInstance: PersistenceProcessor {
        struct Singleton {
            static let instance = PersistenceProcessor()
        }
        return Singleton.instance
    }
    
    let database: SQLiteDB
    
    init() {
        
        database = SQLiteDB(name: "wetalk") { (db: COpaquePointer) -> Void in
            
            let sql_stmt = "CREATE TABLE IF NOT EXISTS FRIEND (id TEXT PRIMARY KEY,UserName TEXT , NickName TEXT, Avatar TEXT, Type INTEGER)"
            if sqlite3_exec(db, sql_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table success")
            }
            
            let session_stmt = "CREATE TABLE IF NOT EXISTS Session (Type TEXT PRIMARY KEY, Value TEXT)"
            if sqlite3_exec(db, session_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table success")
            }
            
            let insert_sql = "INSERT INTO Session(Type, Value) VALUES ('syncKey',  '0')"
            if sqlite3_exec(db, insert_sql, nil, nil, nil) != SQLITE_OK {
                println("insert ")
            }
            
        }
        
    }
    
    func addFriend(friend: User) {
        database.execute("INSERT INTO FRIEND(id, UserName, NickName, Avatar, Type) VALUES ('\(friend.id)',  '\(friend.name)',  '\(friend.nick)', '\(friend.avatar)', '\(friend.userType.rawValue)' )")
    }
    
    func deleteFriend(friend: User) {
        
    }
    
    func getFriends() -> Array<User> {
        let data = database.query("SELECT UserName, NickName, Avatar, Type FROM FRIEND")
        
        var users = [User]()
        for row in data {
            let id = row["id"]?.asString()
            let userName = row["UserName"]?.asString()
            let nickName = row["NickName"]?.asString()
            let avatar = row["Avatar"]?.asString()
            let userType = row["Type"]?.asInt()
            users.append( User(id: id!, name: userName!, nick: nickName!, avatar: avatar!, userType: UserType(rawValue: userType!)!))
        }
        return users
    }
    
    func getSyncKey() -> String {
        let data = database.query("SELECT Value FROM Session WHERE Type = 'syncKey'")
        if let row = data.first? {
            if let syncKey = row["Value"]?.asString() {
                return syncKey
            }
        }
        return "0"
    }
    
    func updateSyncKey(syncKey: Int) {
        database.execute("UPDATE Session SET Value = '\(syncKey)' WHERE Type = 'syncKey'")
    }
    
    func createChatTable(id: String) {
        //init(seqNo: Int64, from: String, to: String, content: String, attach: String?, timestamp: Int64, status: MessageStatus = .Receive)
        database.execute("CREATE TABLE IF NOT EXISTS 'Chat_\(id)' (Id INTEGER PRIMARY KEY AUTOINCREMENT, fromId String, toId String, content TEXT, attach Text, timestamp Integer, status Integer, messageType Integer)")
    }
    
    func addMessage(message: Message) {
        if let attach = message.attach? {
            database.execute("INSERT INTO 'Chat_\(message.from)' (fromId, toId, content, attach, timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', '\(attach)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
        }
        else {
            database.execute("INSERT INTO 'Chat_\(message.from)' (fromId, toId, content,  timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
            
        }
    }
    
    func sendMessage(message: Message) {
        if let attach = message.attach? {
            database.execute("INSERT INTO 'Chat_\(message.to)' (fromId, toId, content, attach, timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', '\(attach)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
        }
        else {
            database.execute("INSERT INTO 'Chat_\(message.to)' (fromId, toId, content, timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
        }
    }
    
    func getRecentChats() -> Array<(String, Message?)> {
        let data = database.query("SELECT name FROM sqlite_master WHERE type='table' and name like 'Chat_%'")
        
        var chats = Array<(String, Message?)>()
        for row in data {
            if let name = row["name"]?.asString() {
                let userName = name.subStringFrom(5)
                let data = database.query("SELECT Id, fromId, toId, content, attach, timestamp, status, messageType FROM '\(name)' ORDER BY Id DESC LIMIT 1")
                if let row = data.first? {
                    let id = row["Id"]?.asInt64()
                    let from = row["fromId"]?.asString()
                    let to = row["toId"]?.asString()
                    let content = row["content"]?.asString()
                    let attach = row["attach"]?.asString()
                    let timestamp = row["timestamp"]?.asInt64()
                    let status = row["status"]?.asInt()
                    let messageType = row["messageType"]?.asInt()
                    
                    //init(seqNo: Int64, from: String, to: String, content: String, attach: String?, timestamp: Int64, status: MessageStatus = .Receive) {
                        
                    let message = Message(seqNo: id!,
                        from: userName,
                        to: to!,
                        content: content!,
                        attach: attach,
                        timestamp: timestamp!,
                        status: MessageStatus(rawValue: status!)!,
                        messageType: MessageType(rawValue: messageType!)!)
                    
                    let element: (String, Message?) = (userName, message)
                    chats.append(element)
                }
                else {
                    let element: (String, Message?) = (userName, nil)
                    chats.append(element)
                }
            }
        }
        return chats
    }
    
    func getRecentMessages(userName: String, page: Int, size: Int = 20) -> Array<Message> {
        let skip = page * size
        let data = database.query("SELECT Id, fromId, toId, content, attach, timestamp, status, messageType FROM 'Chat_\(userName)' ORDER BY Id DESC LIMIT \(skip), \(size)")
        var messages = [Message]()
        for row in data {
            let id = row["Id"]?.asInt64()
            let from = row["fromId"]?.asString()
            let to = row["toId"]?.asString()
            let content = row["content"]?.asString()
            let attach = row["attach"]?.asString()
            let timestamp = row["timestamp"]?.asInt64()
            let status = row["status"]?.asInt()
            let messageType = row["messageType"]?.asInt()
            
                
            let message = Message(seqNo: id!,
                from: userName,
                to: to!,
                content: content!,
                attach: attach,
                timestamp: timestamp!,
                status: MessageStatus(rawValue: status!)!,
                messageType: MessageType(rawValue: messageType!)!)
            
            messages.append(message)
        }
        return messages.reverse()
    }
}