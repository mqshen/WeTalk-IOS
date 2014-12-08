//
//  QNCrc32.swift
//  WeTalk
//
//  Created by GoldRatio on 12/4/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

let kQNBlockSize = 4 * 1024 * 1024
class QNCrc32
{
    class func data(data: NSData) -> UInt32 {
        return CRC.crc32(data)
    }
    
//    class func file(filePath: String, error: NSError) -> UInt32 {
//        if let data = NSData(contentsOfFile:defaultPath, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: error) {
//            
//            let len = data.length;
//            let count = (len + kQNBlockSize - 1) / kQNBlockSize
//            
//            let crc = crc32(0, Z_NULL, 0)
//            for index in 0 ..< count {
//                let offset = i * kQNBlockSize;
//                var size = len - offset
//                if (len - offset) > kQNBlockSize {
//                    size = kQNBlockSize
//                }
//                let d = data.subdataWithRange(NSMakeRange(offset, size))
//                crc = crc32(crc, d.bytes, d.length)
//            }
//            return crc
//        }
//    }
}