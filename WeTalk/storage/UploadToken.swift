//
//  UploadToken.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class UploadToken: Serializable
{

    
    struct Singleton {
        static let sk = "_vajoiKTqA1UWK8sss-jBgicJ6343pecYYbLZNrh"
        //static let sk = "MY_SECRET_KEY"
        static let ak = "iuVNU8hS-LI4lZIOHNI_gHDZaa_JWr8Whh7ySoGY"
    }
    
    let scope: String
    
    let deadline = 1451491200
    
    //let returnBody = "{\"name\":$(fname),\"size\":$(fsize)}"
    let returnBody = "{\"name\":$(fname),\"size\":$(fsize),\"w\":$(imageInfo.width),\"h\":$(imageInfo.height),\"hash\":$(etag)}"
    
    init(fileName: String) {
        //scope = "my-bucket:\(fileName)"
        scope = "mqshen:\(fileName)"
        super.init(json: nil)
    }

    required init(json: JSON) {
        fatalError("init(json:) has not been implemented")
    }

    required init(integerLiteral value: IntegerLiteralType) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
    
    func token() -> String {
        let putPolicy = self.toJsonString()
        var encodedPutPolicy = urlsafe_base64_encode(putPolicy)
        
        var sign = hmac_sha1(encodedPutPolicy, Singleton.sk)
        println(sign)
        var encodedSign = sign.stringByReplacingOccurrencesOfString("+", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var uploadToken = "\(Singleton.ak):\(encodedSign):\(encodedPutPolicy)"
        println(uploadToken)
        return uploadToken
    }
    
}