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
                println("create table friend failed")
            }
            let grop_stmt = "CREATE TABLE IF NOT EXISTS GroupTable (Id TEXT PRIMARY KEY,UserName TEXT , NickName TEXT, Avatar TEXT, Type INTEGER)"
            if sqlite3_exec(db, grop_stmt , nil, nil, nil) != SQLITE_OK {
                println("create table group failed")
            }
            
            let friend_ext_stmt = "CREATE TABLE IF NOT EXISTS FriendExt (Id TEXT PRIMARY KEY,Remark TEXT, GroupMember TEXT)"
            if sqlite3_exec(db, friend_ext_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table friend ext failed")
            }
            
            let session_stmt = "CREATE TABLE IF NOT EXISTS Session (Type TEXT PRIMARY KEY, Value TEXT)"
            if sqlite3_exec(db, session_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table session failed")
            }
            
            let insert_sql = "INSERT INTO Session(Type, Value) VALUES ('syncKey',  '-1')"
            if sqlite3_exec(db, insert_sql, nil, nil, nil) != SQLITE_OK {
                println("failed ")
            }
            
            let add_stmt = "CREATE TABLE IF NOT EXISTS REQUESTFRIEND (id TEXT PRIMARY KEY,UserName TEXT , NickName TEXT, Avatar TEXT, Greeting TEXT, Type INTEGER)"
            if sqlite3_exec(db, add_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table request friend failed")
            }
        }
    }
    
    func addFriend(friend: User) {
        database.execute("INSERT INTO FRIEND(id, UserName, NickName, Avatar, Type) VALUES ('\(friend.id)',  '\(friend.name)',  '\(friend.nick)', '\(friend.avatar)', '\(friend.userType.rawValue)' )")
    }
    
    func addGroup(group: Group) {
        database.execute("INSERT INTO GroupTable(Id, UserName, NickName, Avatar, Type) VALUES ('\(group.id)',  '\(group.name)',  '\(group.name)', '\(group.avatar)', '1' )")
        
        let memebers = ";".join(group.members)
        
        database.execute("INSERT INTO FriendExt(Id, GroupMember) VALUES ('\(group.id)',  '\(memebers)')")
    }
    
    func getGroup() -> Array<Group> {
        let data = database.query("SELECT Id, UserName, NickName, Avatar, Type FROM GroupTable")
        
        var users = [Group]()
        for row in data {
            let id = row["Id"]?.asString()
            let userName = row["UserName"]?.asString()
            let nickName = row["NickName"]?.asString()
            let avatar = row["Avatar"]?.asString()
            let userType = row["Type"]?.asInt()
            
            var memebers = [String]()
            let memberData = database.query("SELECT GroupMember FROM FriendExt where id = '\(id!)'")
            if let memberRow = memberData.first? {
                let member = memberRow["GroupMember"]?.asString()
                memebers = split(member!) {$0 == ";"}
            }
            
            users.append( Group(id: id!, name: userName!, members: memebers))
        }
        return users
    }
    
    func deleteFriend(friend: User) {
        
    }
    
    func getFriends() -> Array<User> {
        let data = database.query("SELECT Id, UserName, NickName, Avatar, Type FROM FRIEND")
        
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
    
    func getSyncKey() -> Int64 {
        let data = database.query("SELECT Value FROM Session WHERE Type = 'syncKey'")
        if let row = data.first? {
            if let syncKey = row["Value"]?.asInt64() {
                return syncKey
            }
        }
        return -1
    }
    
    func updateSyncKey(syncKey: Int64) {
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
    
    func sendMessage(message: Message) -> Int? {
        if let attach = message.attach? {
            database.execute("INSERT INTO 'Chat_\(message.to)' (fromId, toId, content, attach, timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', '\(attach)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
        }
        else {
            database.execute("INSERT INTO 'Chat_\(message.to)' (fromId, toId, content, timestamp, status, messageType) VALUES ('\(message.from)', '\(message.to)', '\(message.content)', \(message.timestamp), \(message.status.rawValue), \(message.messageType.rawValue))")
        }
        let idData = database.query("SELECT last_insert_rowid() Id FROM 'Chat_\(message.to)'")
        if let row = idData.first? {
            let id = row["Id"]?.asInt()
            return id
        }
        return nil
    }
    
    func getRecentChats() -> Array<(String, UserType, Message?)> {
        let data = database.query("SELECT name FROM sqlite_master WHERE type='table' and name like 'Chat_%'")
        
        var chats = Array<(String, UserType, Message?)>()
        for row in data {
            if let name = row["name"]?.asString() {
                var userId = name.subStringFrom(5)
                var userType = UserType.User
                if userId.rangeOfString("@room") != nil{
                    userType = UserType.Room
                }
                let data = database.query("SELECT Id, fromId, toId, content, attach, timestamp, status, messageType FROM '\(name)' ORDER BY Id DESC LIMIT 1")
                if let row = data.first? {
                    let id = row["Id"]?.asString()
                    let from = row["fromId"]?.asString()
                    let to = row["toId"]?.asString()
                    let content = row["content"]?.asString()
                    let attach = row["attach"]?.asString()
                    let timestamp = row["timestamp"]?.asInt64()
                    let status = row["status"]?.asInt()
                    let messageType = row["messageType"]?.asInt()
                    
                    //init(seqNo: Int64, from: String, to: String, content: String, attach: String?, timestamp: Int64, status: MessageStatus = .Receive) {
                        
                    let message = Message(seqNo: id!,
                        from: userId,
                        to: to!,
                        content: content!,
                        attach: attach,
                        timestamp: timestamp!,
                        status: MessageStatus(rawValue: status!)!,
                        messageType: MessageType(rawValue: messageType!)!)
                    
                    let element: (String, UserType, Message?) = (userId, userType, message)
                    chats.append(element)
                }
                else {
                    let element: (String, UserType, Message?) = (userId, userType, nil)
                    chats.append(element)
                }
            }
        }
        return chats
    }
    
    func getRecentMessages(userName: String, page: Int, size: Int = 20) -> Array<Message> {
        let skip = page * size
        let data = database.query("SELECT Id, fromId, toId, content, attach, timestamp, status, messageType FROM 'Chat_\(userName)' ORDER BY timestamp DESC LIMIT \(skip), \(size)")
        var messages = [Message]()
        for row in data {
            let id = row["Id"]?.asString()
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
    
    func setMessageTimeout(message: Message) {
        if let id = message.id? {
             database.execute("UPDATE 'Chat_\(message.to)' SET Status = '\(MessageStatus.Timeout.rawValue)' WHERE id = \(id)")
        }
    }
    
    func getRequestFriend() -> [(User, String)] {
        let data = database.query("SELECT Id, UserName, NickName, Avatar, Type, Greeting FROM REQUESTFRIEND")
        
        var users = [(User, String)]()
        for row in data {
            let id = row["id"]?.asString()
            let userName = row["UserName"]?.asString()
            let nickName = row["NickName"]?.asString()
            let avatar = row["Avatar"]?.asString()
            let userType = row["Type"]?.asInt()
            let greeting = row["Greeting"]?.asString()
            
            let user = User(id: id!, name: userName!, nick: nickName!, avatar: avatar!, userType: UserType(rawValue: userType!)!)
            let element: (User, String) = (user, greeting!)
            users.append( element)
        }
        return users
    }
    
    
    func addRequestFriend(user: User, greeting: String) {
        database.execute("INSERT INTO REQUESTFRIEND(id, UserName, NickName, Avatar, Greeting, Type) VALUES ('\(user.id)',  '\(user.name)',  '\(user.nick)', '\(user.avatar)', '\(greeting)', '\(user.userType.rawValue)')")
    }
}