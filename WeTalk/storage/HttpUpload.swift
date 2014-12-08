//
//  HttpUpload.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import Alamofire

func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
    
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    let boundaryConstant = "myRandomBoundary12345";
    let contentType = "multipart/form-data;boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    // add image
    uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData(imageData)
    
    // add parameters
    for (key, value) in parameters {
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    
    
    // return URLRequestConvertible and NSData
    return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
}