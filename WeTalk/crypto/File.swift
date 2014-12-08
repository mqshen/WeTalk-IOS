//
//  File.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation


func hmac_sha1(input: String, privateKey: String) -> String {
    var output = ""
    if let data = input.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
        if let pkData = privateKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            if let outputData = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH)) {
                let resultBytes = UnsafeMutablePointer<CUnsignedChar>(outputData.mutableBytes)
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), pkData.bytes, UInt(pkData.length), data.bytes, UInt(data.length), resultBytes)
                output = outputData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            }
        }
    }
    return output
}

func urlsafe_base64_encode(input: String) -> String {
    let stringData = input.dataUsingEncoding(NSUTF8StringEncoding)!
        .base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
    return stringData
    //println(stringData)
    //let stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
    //return stringData.stringByReplacingOccurrencesOfString("+", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("/", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
}