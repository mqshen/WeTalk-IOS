//
//  ProgressView.swift
//  WeTalk
//
//  Created by GoldRatio on 12/9/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class ProgressView: UIView {

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    var trackColor: UIColor = UIColor.lightGrayColor()
    var progressColor: UIColor = UIColor.whiteColor()
    var _progress: Double = 0.0
    
    var progress: Double {
        get {
            return _progress
        }
        set {
            _progress = newValue
            self.setNeedsDisplay()
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        let centerPoint = CGPointMake(rect.size.height / 2, rect.size.width / 2)
        let radius = min(rect.size.height, rect.size.width) / 2
        let pathWidth = radius * 0.3
        
        let radians: CGFloat = CGFloat( (1.5 - 2 * self.progress) * M_PI )
        let xOffset = radius * CGFloat(1.0 + 0.85 * cos(radians))
        let yOffset = radius * CGFloat(1.0 + 0.85 * sin(radians))
        let endPoint = CGPointMake(xOffset, yOffset)
        
        let context = UIGraphicsGetCurrentContext()
        
        self.trackColor.setFill()
        
        let trackPath = CGPathCreateMutable()
        CGPathMoveToPoint(trackPath, nil, centerPoint.x, centerPoint.y)
        CGPathAddArc(trackPath, nil, centerPoint.x, centerPoint.y, radius, CGFloat(M_PI * 1.5), CGFloat( -M_PI / 2), true);
        CGPathCloseSubpath(trackPath)
        CGContextAddPath(context, trackPath)
        CGContextFillPath(context)
        
        //CGPathRelease(trackPath)
        
        self.progressColor.setFill()
        let progressPath = CGPathCreateMutable()
        CGPathMoveToPoint(progressPath, nil, centerPoint.x, centerPoint.y)
        CGPathAddArc(progressPath, nil, centerPoint.x, centerPoint.y, radius, CGFloat(1.5 * M_PI), radians, true)
        CGPathCloseSubpath(progressPath)
        CGContextAddPath(context, progressPath)
        CGContextFillPath(context)
        //CGPathRelease(progressPath)
        
        CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth/2, 0, pathWidth, pathWidth))
        CGContextFillPath(context)
        
        CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth/2, endPoint.y - pathWidth/2, pathWidth, pathWidth))
        CGContextFillPath(context)
        
        CGContextSetBlendMode(context, kCGBlendModeClear)
        let innerRadius = radius * 0.7
        let newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius)
        CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2))
        CGContextFillPath(context)
    }
}