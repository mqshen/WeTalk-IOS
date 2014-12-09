//
//  SWWebImageView.swift
//  SWWebImage
//
//  Created by GoldRatio on 8/14/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

public protocol SWWebImageOperation {
    func cancel()
}

public struct SWWebImageOptions : RawOptionSetType {
    private let value: UInt = 0
    
    public init(nilLiteral: ()) {self.value = 0}
    public init(rawValue value: UInt) { self.value = value }
    var boolValue: Bool { return self.value != 0 }
    
    public var rawValue: UInt { return value }

    
    public static var allZeros: SWWebImageOptions { return self(rawValue: 0) }
    public static var None: SWWebImageOptions          { return self(rawValue: 0) }
    public static var RetryFailed: SWWebImageOptions   { return self(rawValue: 1 << 0) }
    public static var LowPriority: SWWebImageOptions  { return self(rawValue: 1 << 1) }
    public static var CacheMemoryOnly: SWWebImageOptions   { return self(rawValue: 1 << 2) }
    public static var ProgressiveDownload: SWWebImageOptions   { return self(rawValue: 1 << 3) }
    public static var RefreshCached: SWWebImageOptions   { return self(rawValue: 1 << 4) }
    public static var ContinueInBackground: SWWebImageOptions   { return self(rawValue: 1 << 5) }
    public static var HandleCookies: SWWebImageOptions   { return self(rawValue: 1 << 6) }
    public static var AllowInvalidSSLCertificates: SWWebImageOptions   { return self(rawValue: 1 << 7) }
    public static var HighPriority: SWWebImageOptions   { return self(rawValue: 1 << 8) }
    public static var DelayPlaceholder: SWWebImageOptions   { return self(rawValue: 1 << 9) }
    public static var TransformAnimatedImage: SWWebImageOptions   { return self(rawValue: 1 << 10) }
}
public func == (lhs: SWWebImageOptions, rhs: SWWebImageOptions) -> Bool     { return lhs.value == rhs.value }

//func &(lhs: SWWebImageOptions, rhs: SWWebImageOptions) -> SWWebImageOptions {
//    return SWWebImageOptions.fromRaw( lhs.value & rhs.value)!
//}
//func |(lhs: SWWebImageOptions, rhs: SWWebImageOptions) -> SWWebImageOptions {
//    return SWWebImageOptions.fromRaw( lhs.value | rhs.value)!
//}
//func ^(lhs: SWWebImageOptions, rhs: SWWebImageOptions) -> SWWebImageOptions {
//    return SWWebImageOptions.fromRaw( lhs.value ^ rhs.value)!
//}
//prefix func ~(lhs: SWWebImageOptions) -> SWWebImageOptions
//{
//    return SWWebImageOptions.fromRaw( ~lhs.value )!
//}

//enum SWWebImageOptions: Int {
//    case RetryFailed = 1
//    case LowPriority = 2
//    case CacheMemoryOnly = 4
//    case ProgressiveDownload = 8
//    case RefreshCached = 16
//    case ContinueInBackground = 32
//    case HandleCookies = 64
//    case AllowInvalidSSLCertificates = 128
//    case HighPriority = 256
//    case DelayPlaceholder = 512
//    case TransformAnimatedImage = 1024
//}

public class SWWebImageView : UIImageView
{
    var operations = Dictionary<String, SWWebImageOperation>()
    
    var url: NSURL?
    
    //func setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
    public func setImage(url: NSURL, placeholderImage: UIImage, options: SWWebImageOptions = SWWebImageOptions.None,
        progress: SWWebImageDownloaderProgressHandler? = nil, completeHandler: SWWebImageCompletedHandler? = nil) {
        self.cancelCurrentImageLoad()
        self.url = url
        if !(options & SWWebImageOptions.DelayPlaceholder).boolValue {
            self.image = placeholderImage
        }
        if let url = self.url? {
            let operation = SWWebImageManager.sharedManager.downloadImage(url, options: options,
                progress: progress,
                completeHandler: {(image: UIImage?, error: NSError?, cacheType: SWImageCacheType , finished: Bool , imageUrl: NSURL? ) -> Void in
                    dispatch_main_sync_safe({ () -> () in
                        if let image = image? {
                            self.image = image
                            self.setNeedsLayout()
                        }
                        else {
                            if (options & SWWebImageOptions.DelayPlaceholder ).boolValue {
                                self.image = placeholderImage;
                                self.setNeedsLayout()
                            }
                        }
                        if let complete = completeHandler? {
                            if (finished) {
                                complete(image, error, cacheType)
                            }
                        }
                    })
                })
            self.operations["UIImageViewImageLoad"] = operation
            //[self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
        }
        else {
            println("url must not be nil")
        }
        
    }
    
    func cancelCurrentImageLoad() {
        self.cancelImageLoadOperationWithKey("UIImageViewImageLoad")
    }
    
    func cancelImageLoadOperationWithKey(key: String) {
        if let op = self.operations[key]? {
            op.cancel()
        }
    }
}