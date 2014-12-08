//
//  ImageMessageView.swift
//  WeTalk
//
//  Created by GoldRatio on 12/7/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ImageMessageView: UIView {
    
    let status: MessageStatus
    
    var _color: UIColor = UIColor.blackColor()
    
    
    var color : UIColor {
        get {
            return _color
        }
        set {
            if _color == newValue {
                return
            }
            _color = newValue
            self.setNeedsDisplay()
        }
    }
    
    var _image: UIImage?
    var image : UIImage? {
        get {
            return _image
        }
        set {
            if _image == newValue {
                return
            }
            _image = newValue
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect, status: MessageStatus) {
        self.status = status
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = UIViewContentMode.Redraw
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        
        let radius: CGFloat = 6
        let margin: CGFloat = 8//留出上下左右的边距
        
        let triangleSize: CGFloat = 8//三角形的边长
        let triangleMarginTop: CGFloat = 8//三角形距离圆角的距离
        
        
        //CGContextBeginPath(context);
        
        let minX: CGFloat = CGRectGetMinX(rect)
        let minY: CGFloat = CGRectGetMinY(rect)
        
        let maxX: CGFloat = CGRectGetMaxX(rect) //minX + width
        let maxY: CGFloat = CGRectGetMaxY(rect) //minX + width
        
        let path = CGPathCreateMutable()
        
        if self.status == .Send {
            
            CGPathAddArc(path, nil, CGFloat(minX + radius), CGFloat(minY + radius), radius, CGFloat(M_PI), CGFloat(M_PI * 3 / 2), false)
            
            //CGContextAddArc(context, CGFloat(minX + radius), CGFloat(minY + radius), radius, CGFloat(M_PI), CGFloat(M_PI * 3 / 2), 0)
            
            CGPathAddLineToPoint(path, nil, CGFloat(maxX - radius - margin), minY)
            
            CGPathAddArc(path, nil, CGFloat(maxX - margin - radius), CGFloat(minY + radius), radius, CGFloat(M_PI * 3 / 2), CGFloat(M_PI * 2), false)
            
            CGPathAddLineToPoint(path, nil, CGFloat(maxX - margin ), minY + triangleMarginTop)
            
            CGPathAddLineToPoint(path, nil, CGFloat(maxX), minY + triangleMarginTop + (triangleSize / 2))
            
            CGPathAddLineToPoint(path, nil, CGFloat(maxX - margin), minY + triangleMarginTop + triangleSize)
            
            CGPathAddLineToPoint(path, nil, CGFloat(maxX - margin), maxY - radius)
            
            CGPathAddArc(path, nil, CGFloat(maxX - margin - radius), CGFloat(maxY - radius), radius, 0, CGFloat(M_PI / 2), false)
            
            CGPathAddLineToPoint(path, nil, CGFloat(minX + radius), maxY)
            
            CGPathAddArc(path, nil, CGFloat(minX + radius), CGFloat(maxY - radius), radius, CGFloat(M_PI / 2), CGFloat(M_PI), false)
            
        }
        else {
            
        }
        
        //CGContextClosePath(context)
        
        //CGContextSetStrokeColorWithColor(context, self.color.CGColor)
        //CGContextStrokePath(context)
        CGContextAddPath(context, path)
        CGContextClip(context)
        if let image = self.image? {
            image.drawInRect(rect)
        }
    }
}