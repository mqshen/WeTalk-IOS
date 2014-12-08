//
//  Serializable.swift
//  WeTalk
//
//  Created by GoldRatio on 11/25/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class Serializable : NSObject {
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
    }
    
    func nsValueForAny(anyValue:Any) -> AnyObject? {
        switch(anyValue) {
        case let intValue as Int:
            return intValue
        case let intValue as Int64:
            return NSNumber(longLong: intValue)
        case let doubleValue as Double:
            return NSNumber(double: CDouble(doubleValue))
        case let stringValue as String:
            return stringValue as NSString
        case let boolValue as Bool:
            return NSNumber(bool: boolValue)
        case let fruitValue as Serializable:
            return fruitValue.toDictionary()
        case let primitiveArrayValue as Array<String>:
            return primitiveArrayValue as NSArray
        case let primitiveArrayValue as Array<Int>:
            return primitiveArrayValue as NSArray
        case let objectArrayValue as Array<Serializable>:
            // this be a tricky one
            return NSNull()
        case let messageType as MessageType:
            return (messageType as MessageType).rawValue
        default:
            return nil
        }
    }
    
    func toDictionary() -> NSDictionary {
        
        var modelDictionary:NSMutableDictionary=NSMutableDictionary()
        
        for var index=0; index<reflect(self).count; ++index {
            let key=reflect(self)[index].0
            println(key)
            let value=reflect(self)[index].1.value
            
            if key=="super" && index==0 {
                // if the first key is super, we should probably skip it
                // because it's most likely the reflector telling us the
                // superclass of this model
                // we'll need to handle this separately
                
                // right now the else is only giving us the K/Vs from
                // the current class. we need to also find a way to get
                // them from the base class.
                
            }
            else {
                if let nsValue = nsValueForAny(value) {
                    println("\(key):\(nsValue)")
                    modelDictionary.setValue(nsValue, forKey: key)
                }
            }
        }
        
        return modelDictionary
    }
    
    func toJson() -> NSData! {
        var dictionary = self.toDictionary()
        var err: NSError?
        return NSJSONSerialization.dataWithJSONObject(dictionary, options:NSJSONWritingOptions(0), error: &err)
    }
    
    func toJsonString() -> NSString! {
        return NSString(data: self.toJson(), encoding: NSUTF8StringEncoding)
    }
    
}