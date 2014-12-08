//
//  MessageCell.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

func horizontallyFlippedImage(image: UIImage) -> UIImage {
    return UIImage(CGImage: image.CGImage, scale: image.scale, orientation: UIImageOrientation.UpMirrored)!
}

func bubbleImageView(color: UIColor, flipped: Bool) -> UIImageView {
    let bubble = UIImage(named: "bubble_min")!
    var normalBubble = bubble.imageMasked(color)
    
    if flipped {
        normalBubble = horizontallyFlippedImage(normalBubble)
        //let capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x)
        let center = UIEdgeInsetsMake(30, 28, 85, 28)
        
        normalBubble = normalBubble.resizableImageWithCapInsets(center, resizingMode: UIImageResizingMode.Stretch)
    }
    else {
        normalBubble = normalBubble.stretchableImageWithLeftCapWidth(10, topCapHeight: 30)
    }
    
    let imageView = UIImageView(image: normalBubble)
    return imageView
}

protocol MessageCellDelegate {
    func didSelectContent(cell: MessageCell)
    func didSelectAvatar(cell: MessageCell)
}

class MessageCell: UITableViewCell
{
    var timeLabel: UILabel?
    var _message: Message?
    var _showTime: Bool = false
    
    var avatarView: SWWebImageView?
    var messageBubbleContainerView: UIView?
    var messageBubbleImageView: MessgeContainter?
    var textView: MessageTextView?
    var messageImageView: ImageMessageView?
    var refresh: UIActivityIndicatorView?
    var delegate: MessageCellDelegate?
    
    func setTime(show: Bool) {
        if _showTime == show {
            //timeLabel?.text = _message?.customData["nickname"]
            return
        }
        if show {
            var frame = self.avatarView!.frame;
            frame.origin.y = 20
            self.avatarView?.frame = frame
            
            frame = self.messageBubbleContainerView!.frame
            frame.origin.y = 20
            self.messageBubbleContainerView?.frame = frame
            self.messageBubbleImageView?.frame = self.messageBubbleContainerView!.bounds
            self.messageBubbleContainerView?.setNeedsDisplay()
            
            if timeLabel == nil {
                timeLabel = UILabel(frame: CGRectMake(0, 0, 320, 20))
                timeLabel!.textAlignment = NSTextAlignment.Center
                timeLabel!.backgroundColor = UIColor.clearColor()
                timeLabel!.font = UIFont.systemFontOfSize(10)
                timeLabel!.textColor = UIColorFromRGB(0x666666)
            }
            let timestamp = _message!.timestamp
            let time = NSDate(timeIntervalSince1970: Double(timestamp / 1000))
            timeLabel?.text = "\(time.detailDateTimeUntilNow())"
            self.addSubview(timeLabel!)
        }
        else {
            var frame = self.avatarView!.frame;
            frame.origin.y = 0
            self.avatarView?.frame = frame
            
            frame = self.messageBubbleContainerView!.frame;
            frame.origin.y = 0;
            self.messageBubbleContainerView?.frame = frame;
            self.messageBubbleImageView?.frame = self.messageBubbleContainerView!.bounds
            self.messageBubbleContainerView?.setNeedsDisplay()
            if let timeLabel = self.timeLabel? {
                timeLabel.removeFromSuperview()
            }
        }
        _showTime = show
    }
    
    func calculateMessageFrame(boundingFrame: CGRect) -> CGRect {
        var frame = self.messageBubbleContainerView!.frame
        frame.size.width = boundingFrame.size.width
        frame.size.height = boundingFrame.size.height
        return frame
    }
    
    var message: Message? {
        get {
            return _message
        }
        set {
            _message = newValue
            if(_message == nil) {
                return
            }
            
            //self.setTime(_message!.needdisplay())
            
            let logo = ""
            let nsurl = NSURL(string: logo)!
            avatarView?.setImage(nsurl, placeholderImage: UIImage(named: "user_placeholder@2x.png")!)
            
            let content = _message!.content
           
            if(self.message!.messageType == .Image) {
                if let image = self.message!.image? {
                    var frame = self.messageImageView!.frame
                    frame.size.width = image.size.width
                    frame.size.height = image.size.height
                    self.messageImageView!.image = image
                    
                    self.messageBubbleContainerView?.frame = calculateMessageFrame(frame)
                    self.messageImageView?.frame = self.messageBubbleContainerView!.bounds
                    //self.messageBubbleContainerView?.backgroundColor = UIColor.redColor()
                }
                //self.messageImageView?.frame = self.messageBubbleContainerView!.bounds
            }
            else {
                textView?.text = content
                let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
                let maximumSize = CGSizeMake(220, CGFloat.max)
                
                // Need to cast stringValue to an NSString in order to call boundingRectWithSize(_:options:attributes:).
                var boundingFrame = content.boundingRectWithSize(maximumSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attributes,
                    context: nil)
                
                //boundingFrame.size.width = max(66, boundingFrame.size.width)
                //boundingFrame.size.height = max(24, boundingFrame.size.height)
                
                self.messageBubbleContainerView?.frame = calculateMessageFrame(boundingFrame)
                self.messageBubbleImageView?.frame = self.messageBubbleContainerView!.bounds
            }
        }
    }
    
    func stopSend(success: Bool) {
        self.refresh?.stopAnimating()
        self.refresh?.removeFromSuperview()
    }
    
    
    func initGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: "didSelectMessageContent")
        let avatarTap = UITapGestureRecognizer(target: self, action: "didSelectAvatar")
        
        self.messageBubbleContainerView?.addGestureRecognizer(tap)
        self.avatarView?.addGestureRecognizer(avatarTap)
    }
    
    func didSelectMessageContent() {
        if(self.delegate != nil) {
            delegate?.didSelectContent(self)
        }
    }
    
    func didSelectAvatar() {
        if(self.delegate != nil) {
            delegate?.didSelectContent(self)
        }
    }
    
    
}

class IncomingMessageCell: MessageCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        avatarView = SWWebImageView(frame: CGRectMake(10, 0, 30, 30))
        //messageBubbleImageView = bubbleImageView(UIColor.whiteColor(), false)
        messageBubbleImageView = MessgeContainter(frame: CGRectZero, status: .Send)
        messageBubbleImageView?.color = UIColor.whiteColor()
        
        messageBubbleContainerView = UIView(frame: CGRectMake(43, 0, 200, 30))
        textView = MessageTextView(frame: CGRectMake(10, 5, 200, 20))
        textView?.backgroundColor = UIColor.clearColor()
        textView?.font = UIFont.systemFontOfSize(14)
        messageBubbleContainerView?.addSubview(textView!)
        
        
        
        //messageBubbleImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        textView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.insertSubview(self.messageBubbleImageView!, belowSubview: self.textView!)
        //self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: -13))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
        
        self.initGestureRecognizer()
    }
}

class IncomingImageMessageCell: MessageCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        avatarView = SWWebImageView(frame: CGRectMake(10, 0, 30, 30))
        //messageBubbleImageView = bubbleImageView(UIColor.whiteColor(), false)
        messageBubbleImageView = MessgeContainter(frame: CGRectZero, status: .Send)
        messageBubbleImageView?.color = UIColor.whiteColor()
        
        messageBubbleContainerView = UIView(frame: CGRectMake(43, 0, 200, 30))
        self.messageImageView = ImageMessageView(frame: CGRectMake(10, 5, 200, 20) , status: .Receive)
        messageImageView?.backgroundColor = UIColor.clearColor()
        messageBubbleContainerView?.addSubview(messageImageView!)
        
        //messageBubbleImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        messageImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.insertSubview(self.messageBubbleImageView!, belowSubview: self.messageImageView!)
        //self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.messageImageView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: -13))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.messageImageView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.messageImageView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.messageImageView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
        self.initGestureRecognizer()
    }
}

class OutgoingMessageCell: MessageCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        avatarView = SWWebImageView(frame: CGRectMake(280, 0, 30, 30))
        //messageBubbleImageView = bubbleImageView(UIColorFromRGB(0x91D052), true)
        messageBubbleImageView = MessgeContainter(frame: CGRectZero, status: .Send)
        messageBubbleImageView?.color = UIColorFromRGB(0x91D052)
        
        messageBubbleContainerView = UIView(frame: CGRectMake(77, 0, 200, 30))
        textView = MessageTextView(frame: CGRectMake(10, 5, 200, 20))
        textView?.backgroundColor = UIColor.clearColor()
        textView?.font = UIFont.systemFontOfSize(14)
        textView?.textColor = UIColor.whiteColor()
        messageBubbleContainerView?.addSubview(textView!)
        
        //messageBubbleImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        textView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.insertSubview(self.messageBubbleImageView!, belowSubview: self.textView!)
        //self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 10))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: -8))
        
        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.textView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 8))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
        self.initGestureRecognizer()
    }
    
    override func calculateMessageFrame(boundingFrame: CGRect) -> CGRect {
        var frame = self.messageBubbleContainerView!.frame
        let width = boundingFrame.size.width + 25
        frame.origin.x = 320 - 43 - width;
        frame.size.width = width
        frame.size.height = boundingFrame.size.height + 16
        return frame
    }
}


class OutgoingImageMessageCell: MessageCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        avatarView = SWWebImageView(frame: CGRectMake(280, 0, 30, 30))
        
//        messageBubbleImageView = MessgeContainter(frame: CGRectZero, status: .Send)//bubbleImageView(UIColorFromRGB(0x91D052), true)
//        messageBubbleImageView?.color = UIColorFromRGB(0x91D052)
        
        messageBubbleContainerView = UIView(frame: CGRectMake(77, 0, 200, 30))
        messageImageView = ImageMessageView(frame: CGRectMake(10, 5, 200, 20), status: .Send)
        messageImageView?.backgroundColor = UIColor.clearColor()
        messageBubbleContainerView?.addSubview(messageImageView!)
        
        messageImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.messageBubbleContainerView?.addSubview(self.messageImageView!)
        //self.messageBubbleContainerView?.pinAllEdgesOf(self.messageBubbleImageView!)
        
//        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
//            attribute: NSLayoutAttribute.Leading,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.messageImageView,
//            attribute: NSLayoutAttribute.Leading,
//            multiplier: 1,
//            constant: -8))
//        
//        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
//            attribute: NSLayoutAttribute.Trailing,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.messageImageView,
//            attribute: NSLayoutAttribute.Trailing,
//            multiplier: 1,
//            constant: 10))
//        
//        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
//            attribute: NSLayoutAttribute.Top,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.messageImageView,
//            attribute: NSLayoutAttribute.Top,
//            multiplier: 1,
//            constant: -8))
//        
//        self.messageBubbleContainerView?.addConstraint(NSLayoutConstraint(item: self.messageBubbleContainerView!,
//            attribute: NSLayoutAttribute.Bottom,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.messageImageView,
//            attribute: NSLayoutAttribute.Bottom,
//            multiplier: 1,
//            constant: 10))
        
        self.addSubview(avatarView!)
        self.addSubview(messageBubbleContainerView!)
        self.initGestureRecognizer()
    }
    
    override func calculateMessageFrame(boundingFrame: CGRect) -> CGRect {
        var frame = self.messageBubbleContainerView!.frame
        let width = boundingFrame.size.width + 25
        frame.origin.x = 320 - 43 - width;
        frame.size.width = width
        frame.size.height = boundingFrame.size.height + 16
        
        if let refresh = self.refresh? {
            var refreshFrame = refresh.frame
            refreshFrame.origin.x = frame.origin.x - 20
            refresh.frame = refreshFrame
        }
        return frame
    }
}