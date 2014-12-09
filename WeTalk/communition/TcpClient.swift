//
//  TcpClient.swift
//  WeTalk
//
//  Created by GoldRatio on 11/25/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import CoreFoundation

public protocol TcpClientDelegate: class {
    func didConnect()
    func didDisconnect(error: NSError?)
    func didWriteError(error: NSError?)
    func didReceiveMessage(text: String)
    func didReceiveData(data: NSData)
}

public class TcpClient : NSObject, NSStreamDelegate {
    let BUFFER_MAX              = 2048
    
    class TcpResponse {
        var isFin = false
        var bytesLeft = 0
        var frameCount = 0
        var buffer: NSMutableData?
    }
    
    //init the websocket with a url
    private let host: String
    private let port: UInt32
    
    
    private var inputStream: NSInputStream?
    private var outputStream: NSOutputStream?
    private var writeQueue: NSOperationQueue?
    private var isRunLoop = false
    private var connected = false
    
    private var inputQueue = Array<NSData>()
    private var fragBuffer: NSData?
    private var readStack = Array<TcpResponse>()
    private var lastResponse: NSData?
    
    public weak var delegate: TcpClientDelegate?
    
    public init(host: String, port: UInt32) {
        self.host = host
        self.port = port
    }
    
    
    public func connect() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
            self.initStreams()
        })
    }
    
    
    private func initStreams() {
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        
        
        isRunLoop = true
        inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream!.open()
        outputStream!.open()
//        let data = "test".dataUsingEncoding(NSUTF8StringEncoding)
//        let bytes = UnsafePointer<UInt8>(data!.bytes)
//        outputStream!.write(bytes, maxLength: data!.length)
        while(isRunLoop) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as NSDate)
        }
    }
    
    private func disconnect(error: NSError?) {
        if writeQueue != nil {
            writeQueue!.waitUntilAllOperationsAreFinished()
        }
        inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
        isRunLoop = false
        connected = false
        dispatch_async(dispatch_get_main_queue(),{
            self.workaroundMethod()
            self.delegate?.didDisconnect(error)
        })
    }
    
    
    //work around for a swift bug. BugID: 17712659
    func workaroundMethod() {
        //does nothing, but fixes bug in swift
    }
    
    
    func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent) {
        
        if eventCode == .OpenCompleted {
            self.connected = true
        }
        else if eventCode == .HasBytesAvailable {
            if(aStream == inputStream) {
                processInputStream()
            }
        } else if eventCode == .ErrorOccurred {
            disconnect(aStream!.streamError)
        } else if eventCode == .EndEncountered {
            disconnect(nil)
        }
    }
    
    private func processInputStream() {
        let buf = NSMutableData(capacity: BUFFER_MAX)
        var buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
        let length = inputStream!.read(buffer, maxLength: BUFFER_MAX)
        if length > 0 {
            var process = false
            if inputQueue.count == 0 {
                process = true
            }
            inputQueue.append(NSData(bytes: buffer, length: length))
            if process {
                dequeueInput()
            }
        }
    }
    
    private func dequeueInput() {
        if inputQueue.count > 0 {
            let data = inputQueue[0]
            var work = data
            if (lastResponse != nil) {
                var combine = NSMutableData(data: lastResponse!)
                combine.appendData(data)
                work = combine
                lastResponse = nil
            }
            let buffer = UnsafePointer<UInt8>(work.bytes)
            processRawMessage(buffer, bufferLen: work.length)
            inputQueue = inputQueue.filter{$0 != data}
            dequeueInput()
        }
    }
    
    private func processRawMessage(buffer: UnsafePointer<UInt8>, bufferLen: Int) {
        var offset = 0
        for index in 1...(bufferLen - 2) {
            if(buffer[index] == 13 && buffer[index + 1] == 10) {
                offset = index + 2
                processResponse(NSData(bytes: buffer, length: index))
            }
        }
        if(offset < bufferLen) {
            let data = NSData(bytes: buffer + offset, length: bufferLen - offset)
            lastResponse = NSData(data: data)
        }
        else {
            lastResponse = nil
        }
    }
    
    public func processResponse(data: NSData) {
        if let message = NSString(data: data, encoding:NSUTF8StringEncoding)? {
            delegate?.didReceiveMessage(message)
        }
    }
    
    public func writeString(str: String) {
        dequeueWrite((str + "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    private func dequeueWrite(data: NSData!) {
        if writeQueue == nil {
            writeQueue = NSOperationQueue()
            writeQueue!.maxConcurrentOperationCount = 1
        }
        writeQueue!.addOperationWithBlock {
            var tries = 0;
            while self.outputStream == nil || !self.connected {
                if(tries < 5) {
                    sleep(1);
                } else {
                    break;
                }
                tries++;
            }
            
            if !self.connected {
                return
            }
            
            
            var total = 0
            let dataLength = data.length
            var offset = 0
            while true {
                if self.outputStream == nil {
                    break
                }
                let writeBuffer = UnsafePointer<UInt8>(data.bytes + total)
                var len = self.outputStream!.write(writeBuffer, maxLength: dataLength-total)
                if len < 0 {
                    self.delegate?.didDisconnect(self.outputStream!.streamError)
                    break
                } else {
                    total += len
                }
                if total >= offset {
                    break
                }
            }
        }
    }
}