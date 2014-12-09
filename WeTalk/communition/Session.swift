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



class User: Serializable {
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
        
        
        //connection = TcpClient(host: "localhost", port: 8100)
        //connection = TcpClient(host: "192.168.32.10", port: 8100)
        connection = TcpClient(host: "192.168.99.181", port: 8100)
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
    
    func getUserById(id: String) -> User? {
        for user in friends {
            if user.id == id {
                return user
            }
        }
        return nil
    }
    
    func didReceiveMessage(text: String) {
        let command = text.subString(0, end: 3)
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
        }
    }
    
    func didReceiveData(data: NSData) {
        
    }
    
    
    func login(userName: String, password: String) {
        let auth = UserAuth(userName: userName, password: password)
        connection.writeString(auth.packageData())
    }
    
    func sendMessage(message: Message) {
        connection.writeString(message.packageData())
    }
    
    func refreshFriends() {
        let refresh = ContactsRefresh(seqNo: 0)
        connection.writeString(refresh.packageData())
        
    }
    
    func getUser(userName: String) -> User? {
        for user in friends {
            if user.name == userName {
                return user
            }
        }
        return nil
    }
}
