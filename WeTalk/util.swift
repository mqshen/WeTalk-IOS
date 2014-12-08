//
//  util.swift
//  WeTalk
//
//  Created by GoldRatio on 11/25/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIImage
{
    func imageMasked(maskColor: UIColor) -> UIImage {
        let imageRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -(imageRect.size.height))
        
        CGContextClipToMask(context, imageRect, self.CGImage)
        CGContextSetFillColorWithColor(context, maskColor.CGColor)
        CGContextFillRect(context, imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}



extension UIView
{
    func pinSubview(view: UIView, attribute: NSLayoutAttribute) {
        self.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }
    
    func pinAllEdgesOf(view: UIView) {
        self.pinSubview(view, attribute: NSLayoutAttribute.Bottom)
        self.pinSubview(view, attribute: NSLayoutAttribute.Top)
        self.pinSubview(view, attribute: NSLayoutAttribute.Leading)
        self.pinSubview(view, attribute: NSLayoutAttribute.Trailing)
    }
}

extension String {
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = self.rangeOfString(sub) {
            if !range.isEmpty {
                pos = distance(self.startIndex, range.startIndex)
            }
        }
        return pos
    }
    
    
    func subString(start: Int, end: Int) -> String {
        let start = advance(self.startIndex, start)
        let end = advance(self.startIndex, end)
        let range = start..<end
        let substr = self[range]
        return substr
    }
    
    func subStringFrom(pos:Int)->String {
        let start = advance(self.startIndex, pos)
        let end = self.endIndex
        let range = start..<end
        let substr = self[range]
        return substr
    }
    
    func subStringTo(pos:Int)->String {
        let end = advance(self.startIndex, pos-1)
        let range = self.startIndex...end
        let substr = self[range]
        return substr
    }
}
