//
//  QNUploadManager.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import Alamofire


public typealias QNUpProgressHandler = (Int64, Int64) -> Void
public typealias QNUpCancellationSignal = () -> Bool

typealias QNUpCompletionHandler = (AnyObject?, NSError?) -> Void

class QNResponseInfo
{

}

class QNUploadOption
{
    let params: [String: String]?
    let mimeType: String?
    let checkCrc: Bool
    let progressHandler: QNUpProgressHandler
    let cancellationSignal: QNUpCancellationSignal
    
    
    
    init(params: [String: String]?, mimeType: String, checkCrc: Bool, progressHandler: QNUpProgressHandler, cancellationSignal: QNUpCancellationSignal) {
        self.params = params
        self.mimeType = mimeType
        self.checkCrc = checkCrc
        self.progressHandler = progressHandler
        self.cancellationSignal = cancellationSignal
    }
    
}

class QNUploadManager
{
    let httpManager = QNHttpManager()
    
    func pudData(data: NSData, key: String, token: String, completionHandler: QNUpCompletionHandler,  progressHandler: QNUpProgressHandler, option: QNUploadOption?) {
        var parameters = [String: String]()
        
        parameters["key"] = key
        parameters["token"] = token
        
        var mimeType = "application/octet-stream"
        
        if let option = option? {
            if let params = option.params? {
                for (k, v) in params {
                    parameters.updateValue(v, forKey: k)
                }
            }
            
            if option.mimeType != nil {
                mimeType = option.mimeType!
            }
            
            if option.checkCrc {
                parameters["crc32"] = "\(QNCrc32.data(data))"
            }
        }
    
        self.httpManager.multipartPost("http://upload.qiniu.com",
            data: data,
            params: parameters,
            fileName: key,
            mimeType: mimeType,
            completeHandler: completionHandler,
            progressHandler: progressHandler)
            { () -> Bool in
                return false
        }
        
        
        
    }
    
    
    class func checkAndNotifyError(key: String, token: String, data: NSData, file: String, completionHandler: QNUpCompletionHandler) {
        
    }
    
    
    
    class var sharedUploadManager: QNUploadManager {
        struct Singleton {
            static let instance = QNUploadManager()
        }
        return Singleton.instance
    }
    
    
    class func postData(data: NSData, fileName: String, completeHandler: QNUpCompletionHandler, progressHandler: QNUpProgressHandler) {
        
        let test = UploadToken(fileName: fileName)
        
        let token = test.token()
        
        let upManager = QNUploadManager.sharedUploadManager
        
        upManager.pudData(data, key: fileName, token: token, completionHandler: completeHandler, progressHandler: progressHandler, option: nil)
        
    }
}