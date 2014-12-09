//
//  MessgeContainter.swift
//  WeTalk
//
//  Created by GoldRatio on 12/7/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class MessgeContainter: UIView {
    
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
        
        
        CGContextBeginPath(context);
        
        let minX: CGFloat = CGRectGetMinX(rect)
        let minY: CGFloat = CGRectGetMinY(rect)
        
        let maxX: CGFloat = CGRectGetMaxX(rect) //minX + width
        let maxY: CGFloat = CGRectGetMaxY(rect) //minX + width
        
        if self.status == .Send {
            CGContextAddArc(context, CGFloat(minX + radius), CGFloat(minY + radius), radius, CGFloat(M_PI), CGFloat(M_PI * 3 / 2), 0)
            
            CGContextAddLineToPoint(context, CGFloat(maxX - radius - margin), minY)
            
            CGContextAddArc(context, CGFloat(maxX - margin - radius), CGFloat(minY + radius), radius, CGFloat(M_PI * 3 / 2), CGFloat(M_PI * 2), 0)
            
            CGContextAddLineToPoint(context, CGFloat(maxX - margin ), minY + triangleMarginTop)
            
            CGContextAddLineToPoint(context, CGFloat(maxX), minY + triangleMarginTop + (triangleSize / 2))
            
            CGContextAddLineToPoint(context, CGFloat(maxX - margin), minY + triangleMarginTop + triangleSize)
            
            CGContextAddLineToPoint(context, CGFloat(maxX - margin), maxY - radius)
            
            CGContextAddArc(context, CGFloat(maxX - margin - radius), CGFloat(maxY - radius), radius, 0, CGFloat(M_PI / 2), 0);
            
            CGContextAddLineToPoint(context, CGFloat(minX + radius), maxY)
            
            CGContextAddArc(context, CGFloat(minX + radius), CGFloat(maxY - radius), radius, CGFloat(M_PI / 2), CGFloat(M_PI), 0)
        }
            
        else {
            
            CGContextAddArc(context, CGFloat(minX + radius + margin), CGFloat(minY + radius), radius, CGFloat(M_PI), CGFloat(M_PI * 3 / 2), 0)
            
            CGContextAddLineToPoint(context, CGFloat(maxX - radius), minY)
            
            CGContextAddArc(context, CGFloat(maxX - radius), CGFloat(minY + radius), radius, CGFloat(M_PI * 3 / 2), CGFloat(M_PI * 2), 0)
            
            CGContextAddLineToPoint(context, maxX, maxY - radius)
            
            CGContextAddArc(context, CGFloat(maxX - radius), CGFloat(maxY - radius), radius, 0, CGFloat(M_PI / 2), 0)
            
            CGContextAddLineToPoint(context, CGFloat(minX + margin + radius), maxY)
            
            CGContextAddArc(context, CGFloat(minX + margin + radius), CGFloat(maxY - radius), radius, CGFloat(M_PI / 2), CGFloat(M_PI), 0)
            
            CGContextAddLineToPoint(context, CGFloat(minX + margin), minY + triangleMarginTop + triangleSize)
            
            CGContextAddLineToPoint(context, CGFloat(minX), minY + triangleMarginTop + (triangleSize / 2))
            
            CGContextAddLineToPoint(context, CGFloat(minX + margin), minY + triangleMarginTop)
            
        }
        
        CGContextClosePath(context)
            
        CGContextSetFillColorWithColor(context, self.color.CGColor)
            
        CGContextFillPath(context)
    }
}