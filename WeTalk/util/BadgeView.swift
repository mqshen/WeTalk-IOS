//
//  BadgeView.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class BadgeView: UIView
{
    var color:UIColor = UIColor.redColor()
    var textColor:UIColor = UIColor.whiteColor()
    var badge: Int = 0
    var padding: CGFloat = 3
    var font: UIFont = UIFont.systemFontOfSize(12)
    var align: NSTextAlignment = NSTextAlignment.Center
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if (self.badge == 0) {
            return
        }
        let badgeStr = "\(self.badge)"
        let maximumLabelSize = CGSizeMake(100, 100);
        
        let attributes = [NSFontAttributeName:self.font,NSForegroundColorAttributeName: self.textColor]
        
        let currentText = NSAttributedString(string: badgeStr, attributes: attributes)
        
        let frame = currentText.boundingRectWithSize(maximumLabelSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let width = frame.size.width + CGFloat(2 * self.padding)
        var puffer: CGFloat = 0;
        
        switch (self.align) {
        case NSTextAlignment.Left:
            puffer = 0
            break
        case NSTextAlignment.Center:
            puffer = (rect.size.width - width) / 2
        default:
            puffer = rect.size.width - width
            break
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        
        let radius: CGFloat = rect.size.height / 2
        
        let minX: CGFloat = CGRectGetMinX(rect) + puffer
        let minY: CGFloat = CGRectGetMinY(rect)
        
        let maxX: CGFloat = minX + width
        //CGFloat maxY = CGRectGetMaxY(rect);
        
        
        CGContextBeginPath(context);
        
        CGContextAddArc(context, CGFloat(minX + radius), CGFloat(minY + radius), radius, CGFloat(M_PI / 2), CGFloat(M_PI * 3 / 2), 0)
        CGContextAddLineToPoint(context, maxX - radius, minY)
        CGContextAddArc(context, CGFloat(maxX - radius), CGFloat(minY + radius), radius, CGFloat(  M_PI / -2), CGFloat(M_PI/2), 0);
        
        
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillPath(context);
        
        let point = CGPointMake(puffer + self.padding, (rect.size.height - frame.size.height) / 2)
        currentText.drawAtPoint(point)
    }
}