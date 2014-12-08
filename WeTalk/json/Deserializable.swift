//
//  Deserializable.swift
//  WeTalk
//
//  Created by GoldRatio on 11/26/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

let classes : Dictionary<String, () -> Serializable.Type> = ["User" : {return User.self }, "Message" : {return Message.self }]

//let types : [(String, Any.Type)] = [("User" , User.self)]


class Deserializable: NSObject {
    
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init()
    }
}

extension JSON {
    
//    func fromDictionary(anyobjectTypeString: String) -> NSObject {
//        var anyobjectype : AnyObject.Type = swiftClassFromString(anyobjectTypeString)
//        var nsobjectype : NSObject.Type = anyobjectype as NSObject.Type
//        var nsobject: NSObject = nsobjectype()
//        for (key: String, value: AnyObject?) in dictionary {
//            if (self[key] != nil) {
//                nsobject.setValue(self[key].object, forKey: key)
//            }
//        }
//        return nsobject
//    }
    
    
    func swiftClassFromString(className: String) -> AnyClass! {
        if  var appName: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String? {
            let classStringName = "\(appName).\(className)"
            return NSClassFromString(classStringName)
        }
        return nil;
    }
    
    func toObject(className: String) -> Serializable {
        let result = classes[className]!()
        
        return result(json: self)
//        for var index=0; index<reflect(result).count; ++index {
//            let key = reflect(result)[index].0
//            let valueType = reflect(result)[index].1.valueType
//            
////            let item = User()
////            println(item.dynamicType)
////            if (valueType is item.Type) {
////                
////            }
////            println(valueType)
//            let value = self[key]
//            if value != nil {
//                
////                for item:(String, Any.Type) in types {
////                    if (valueType is item.1) {
////                        
////                    }
////                }
//                //result.setValue(value.object, forKey: propName)
//                switch valueType {
//                case _ as User.Type:
//                    result
//                    reflect(result)[index].1.value = value.toObject("User")
//                case _ as UserType.Type:
//                    reflect(result)[index].1.value = UserType(rawValue: value.int!)
//                default:
//                    reflect(result)[index].1.value = value.object
//                }
//            }
//        }
////        var propertiesCount : CUnsignedInt = 0
////        let propertiesInAClass : UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(result.dynamicType, &propertiesCount)
////        var propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
//        
////        for var i = 0; i < Int(propertiesCount); i++ {
////            let property = propertiesInAClass[i]
////            let propName = String(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
////            println(propName)
////            let propType = property_getAttributes(property)
////            let typeString = NSString(CString: propType, encoding: NSASCIIStringEncoding)!
////            let propTypes = typeString.componentsSeparatedByString(",") as [String]
////            let type: String = propTypes[0]
////            let length = countElements(type)
////            if length > 4 {
////                let value = self[propName]
////                let index = advance(type.startIndex, 3)
////                let index2 = advance(type.endIndex, -1)
////                let range = Range<String.Index>(start: index,end: index2)
////                
////                let className = type.substringWithRange(range)
////                if let instance  = classes[className]? {
////                    let val: AnyObject = value.toObject(className)
////                    //result.setValue(val, forKey: propName)
////                }
////            }
////            else {
////                let value = self[propName]
////                if value != nil {
////                    result.setValue(value.object, forKey: propName)
////                }
////            }
////
////        }
        
    }
}