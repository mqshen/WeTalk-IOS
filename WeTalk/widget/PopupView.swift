//
//  PopupView.swift
//  Campfire
//
//  Created by GoldRatio on 9/6/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

let POPUP_ROOT_SIZE = CGSizeMake(10, 5)

class TouchPeekView: UIView
{
    var delegate: PopupView?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let view = self.delegate? {
            view.hide()
        }
    }
}

class PopupView: UIView
{
    
    var horizontalOffset: CGFloat
    
    var peekView: TouchPeekView?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        horizontalOffset = -frame.origin.x
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.layer.anchorPoint = CGPointMake(0.8, 0.05)
    }
    
    
    //var popupRect:CGRect = CGRectMake(0, 0, 100, 100)
    var pointToBeShown: CGPoint = CGPointZero
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.8)
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 2, UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).CGColor)
        
        self.makePathCircleCornerRect(rect, radius: 4, popPoint: pointToBeShown)
        
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        //        CGContextSaveGState(context)
        //        self.makePathCircleCornerRect(popupRect, radius: 4, popPoint: pointToBeShown)
        //
        //
        //        CGContextDrawLinearGradient(context,
        //            gradient,
        //            CGPointMake(0, popupRect.origin.y),
        //            CGPointMake(0, popupRect.origin.y + (popupRect.size.height-POPUP_ROOT_SIZE.height)/2), 0)
        //
        //        CGContextDrawLinearGradient(context,
        //            gradient2,
        //            CGPointMake(0, popupRect.origin.y + (popupRect.size.height-POPUP_ROOT_SIZE.height)/2),
        //            CGPointMake(0, popupRect.origin.y + popupRect.size.height-POPUP_ROOT_SIZE.height), 0)
        //        CGContextRestoreGState(context)
        
    }
    
    func makePathCircleCornerRect(viewRect: CGRect, radius: CGFloat, popPoint: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        var rect = viewRect
        rect.size.height -= POPUP_ROOT_SIZE.height
        
        let minx = CGRectGetMinX( rect )
        let maxx = CGRectGetMaxX( rect )
        
        let miny = CGRectGetMinY( rect ) + POPUP_ROOT_SIZE.height
        let maxy = CGRectGetMaxY( rect )
        
        //        let popRightEdgeX = popPoint.x + POPUP_ROOT_SIZE.width / 2
        //        let popRightEdgeY = maxy
        //
        //        let popLeftEdgeX = popPoint.x - POPUP_ROOT_SIZE.width / 2
        //        let popLeftEdgeY = maxy
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, minx, miny + radius)
        
        CGContextAddArc(context, minx + radius, miny + radius, radius, CGFloat(M_PI), CGFloat(M_PI_2 * 3), 0)
        CGContextAddLineToPoint(context, maxx - radius - 10 - POPUP_ROOT_SIZE.width, miny)
        CGContextAddLineToPoint(context, maxx - radius - 10 - (POPUP_ROOT_SIZE.width / 2), miny - POPUP_ROOT_SIZE.height)
        CGContextAddLineToPoint(context, maxx - radius - 10 , miny)
        CGContextAddLineToPoint(context, maxx - radius, miny)
        
        
        CGContextAddArc(context, maxx - radius, miny + radius, radius, CGFloat(M_PI_2 * 3), CGFloat(M_PI * 2), 0)
        CGContextAddLineToPoint(context, maxx, maxy - radius)
        
        
        CGContextAddArc(context, maxx - radius, maxy - radius, radius, 0, CGFloat(M_PI_2), 0)
        CGContextAddLineToPoint(context, minx + radius, maxy )
        
        CGContextAddArc(context, minx + radius, maxy - radius, radius, CGFloat(M_PI_2), CGFloat(M_PI), 0)
        
        
        //        CGContextAddArcToPoint(context, minx, miny, midx, miny, radius)
        //        CGContextAddLineToPoint(context, popRightEdgeX, popRightEdgeY)
        //
        //        CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius)
        //        CGContextAddArcToPoint(context, maxx, maxy, popRightEdgeX, popRightEdgeY, radius)
        //
        //        CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius)
        //        CGContextAddLineToPoint(context, popPoint.x, popPoint.y)
        //
        //        CGContextAddLineToPoint(context, popLeftEdgeX, popLeftEdgeY)
        //        CGContextAddLineToPoint(context, minx, midy)
        CGContextClosePath(context)
        
    }
    
    
    func showAtPoint(point: CGPoint, inView:UIView, animated:Bool) {
        
        let pointToBeShown = point
        
    }
    
    func popup() {
//        
        self.createAndAttachTouchPeekView()
//        
//        let positionAnimation = self.getPositionAnimationForPopup()
//        let alphaAnimation = self.getAlphaAnimationForPopup()
//        let group = CAAnimationGroup()
//        group.animations = [positionAnimation, alphaAnimation]
//        group.duration = 0.2
//        group.removedOnCompletion = true
//        group.fillMode = kCAFillModeForwards
//        
//        let frame = self.frame
//        let maxx = CGRectGetMaxX( frame )
//        let midy = CGRectGetMinY( frame )
//        
//        let anchorPoint = self.layer.anchorPoint
//        self.layer.anchorPoint = CGPointMake(1.0, 0)
//        
//        self.layer.addAnimation(group, forKey: "hoge")
        
        self.peekView?.addSubview(self)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
        })
        
    }
    

    func createAndAttachTouchPeekView() {
        self.transform = CGAffineTransformMakeScale(0.0, 0.0);
        if let peekView = self.peekView? {
            peekView.removeFromSuperview()
        }
        if let window = UIApplication.sharedApplication().keyWindow? {
            self.peekView = TouchPeekView(frame: window.frame)
            self.peekView?.delegate = self
            window.addSubview(self.peekView!)
        }
    }
    
    func hide() {
        self.peekView?.removeFromSuperview()
    }
    
    override func animationDidStop(anim: CAAnimation!, finished : Bool) {
        if finished {
            self.peekView?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
}
