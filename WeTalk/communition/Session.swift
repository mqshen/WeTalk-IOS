//
//  Session.swift
//  WeTalk
//
//  Created by GoldRatio on 12/2/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

let LoginNotification = "loginNotification"

enum UserType: Int{
    case User, Room
}

protocol Chatable {
    var id: String{ get }
    var name: String{ get }
    var nick: String{ get }
    var avatar: String{ get }
    var userType: UserType{ get }
}

class User: Serializable, Chatable {
    var id: String
    var name: String
    var nick: String
    var avatar: String
    var userType: UserType
    
    required init(json: JSON) {
        if let id = json["id"].int64? {
            self.id = "\(id)"
        }
        else {
            self.id = ""
        }
        
        if let name = json["name"].string? {
            self.name = name
        }
        else {
            self.name = ""
        }
        
        if let nick = json["nick"].string? {
            self.nick = nick
        }
        else {
            self.nick = ""
        }
        
        
        if let avatar = json["avatar"].string? {
            self.avatar = avatar
        }
        else {
            self.avatar = ""
        }
        
        if let userType = json["userType"].int? {
            self.userType = UserType(rawValue: userType)!
        }
        else {
            self.userType = UserType.User
        }
        super.init(json: json)
        
    }
   
    
    init(id: String, name: String, nick: String, avatar: String, userType: UserType) {
        self.id = id
        self.name = name
        self.nick = nick
        self.avatar = avatar
        self.userType = userType
        super.init()
    }

    required init(integerLiteral value: IntegerLiteralType) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
}




class Session: TcpClientDelegate {
    var friends = Array<User>()
    var groups:[Group] = Array<Group>()
    
    private var _messageId: Int64 = 0
    var messageId: String {
        get {
            return "\(_messageId++)"
        }
    }
    
    var packageProcessors = [String: Command]()
    
    var connection: TcpClient
    
    class var sharedInstance: Session {
        struct Singleton {
            static let instance = Session()
        }
        return Singleton.instance
    }
    
    var sessionId: String?
    var user: User?
    
    
    init() {
        let loginProcessor = LoginProcessor()
        packageProcessors[loginProcessor.responseKey()] = loginProcessor
        
        
        connection = TcpClient(host: "localhost", port: 8100)
        //connection = TcpClient(host: "192.168.32.10", port: 8100)
        //connection = TcpClient(host: "192.168.99.181", port: 8100)
        connection.delegate = self
        connection.connect()
    }
    
    
    func didConnect() {
        //self.checkLogin();
    }
    
    func didDisconnect(error: NSError?) {
        
    }
    
    func didWriteError(error: NSError?) {
        
    }
    
    func getUserById(id: String, userType: UserType = .User) -> Chatable? {
        if userType == .User {
            for user in friends {
                if user.id == id {
                    return user
                }
            }
        }
        else {
            for group in groups {
                println(group.members)
                if id == group.id {
                    return group
                }
            }
            
        }
        return nil
    }
    
    func didReceiveMessage(text: String) {
        let command = text.subString(0, end: 3)
        println(text)
        if let processor = self.packageProcessors[command]? {
            let index = advance(text.startIndex, 4)
            let index2 = advance(text.endIndex, 0)
            let range = Range<String.Index>(start: index,end: index2)
            
            let jsonString = text.substringWithRange(range)
            
            let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            let json = JSON(data: data!)
            
            if (json["ec"].number == 0) {
                processor.handle(json)
            }
            else {
                
            }
        }
    }
    
    func didReceiveData(data: NSData) {
        
    }
    
    
    func login(userName: String, password: String) {
        let auth = UserAuth(userName: userName, password: password)
        TimeoutManager.sharedInstance.addCommand(auth)
        connection.writeString(auth.packageData())
    }
    
    func sendMessage(command: TimeoutCheckable) {
        TimeoutManager.sharedInstance.addCommand(command)
        connection.writeString(command.packageData())
    }
    
    func sendString(message: String) {
        connection.writeString(message)
    }
    
    func createGroup(name: String, members: [String]) {
        let group = GroupRequest(name: name, members: members)
        connection.writeString(group.packageData())
    }
    
    func refreshFriends() {
        
        let syncKey = PersistenceProcessor.sharedInstance.getSyncKey()
        if syncKey < 0 {
            let refresh = ContactsRefresh()
            connection.writeString(refresh.packageData())
            
            let refreshGroups = ListGroup()
            connection.writeString(refreshGroups.packageData())
            PersistenceProcessor.sharedInstance.updateSyncKey(0)
        }
        else {
            self.friends = PersistenceProcessor.sharedInstance.getFriends()
            self.groups = PersistenceProcessor.sharedInstance.getGroup()
            let syncProcessor = UserSyncProcessor()
            self.packageProcessors[syncProcessor.responseKey()] = syncProcessor
            let userSync = UserSync(syncKey: syncKey, userId: 0)
            connection.writeString(userSync.packageData())
        }
    }
    
    func getUser(userName: String) -> User? {
        for user in friends {
            if user.name == userName {
                return user
            }
        }
        return nil
    }
    
    func addProcessor(processor: Command) {
        packageProcessors[processor.responseKey()] = processor
    }
    
    func setFriendOperateViewController(delegate: FriendOperateDelegate?) {
        if let processor = packageProcessors["5:3"]? {
            if let friendProcessor = processor as? FriendOperateProcessor {
                friendProcessor.delegate = delegate
            }
        }
    }
    
}
