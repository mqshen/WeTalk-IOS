//
//  QNHttpManager.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class QNHttpManager {
    
    
    
    func multipartPost(url: String, data: NSData, params: [String: String], fileName: String, mimeType: String,
        completeHandler: QNUpCompletionHandler,
        progressHandler: QNUpProgressHandler,
        cancelHandler: QNUpCancellationSignal) {
            
            let urlRequest = urlRequestWithComponents(url, params, data)
            
            Alamofire.upload(urlRequest.0, urlRequest.1)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    progressHandler(totalBytesWritten, totalBytesExpectedToWrite)
                }
                .responseJSON { (request, response, json, error) in
                    
                    completeHandler(json, error)
                    println("REQUEST \(request)")
                    println("RESPONSE \(response)")
                    println("JSON \(json)")
                    println("ERROR \(error)")
            }
    }
}