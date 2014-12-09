//
//  ThumbImage.swift
//  WeTalk
//
//  Created by GoldRatio on 12/7/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func thumbnailWithImageWithoutScale(size: CGSize) -> UIImage {
        let oldsize = self.size
        var rect = CGRectZero
        
        if (size.width/size.height > oldsize.width/oldsize.height) {
            rect.size.width = size.height * oldsize.width/oldsize.height
            rect.size.height = size.height
        }
        else {
            rect.size.width = size.width
            rect.size.height = size.width*oldsize.height/oldsize.width
        }
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        UIRectFill(CGRectMake(0, 0, size.width, size.height))//clear background 
        self.drawInRect(rect)
        
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
        
        return newimage
    }
    
    func base64String() -> String {
        return UIImagePNGRepresentation(self).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    
    func maskImage(maskImage: UIImage!) -> UIImage {
        
        let maskRef: CGImageRef! = maskImage.CGImage
        let mask: CGImageRef! = CGImageMaskCreate(CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), nil, true)
        
        let sourceImage: CGImageRef! = self.CGImage
        let masked: CGImageRef! = CGImageCreateWithMask(sourceImage, mask)
        
        var maskedImage = UIImage(CGImage: masked)
        
        return maskedImage!
    }
}