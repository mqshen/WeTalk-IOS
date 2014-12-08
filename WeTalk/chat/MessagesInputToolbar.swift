//
//  MessagesInputToolbar.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

protocol MessageInputViewDelegate: UITextViewDelegate
{
    func didSelectedMultipleMediaAction(change: Bool)
    func didSelectedVoice(change: Bool)
}

class MessagesInputToolbar: UIView, AVAudioRecorderDelegate
{
    let contentView: MessagesComposerTextView
    let mediaButton: UIButton
    var inputDelegate: MessageInputViewDelegate?
    
    var textInput: Bool = true
    
    var delegate: MessageInputViewDelegate? {
        get {
            return self.inputDelegate
        }
        set {
            self.inputDelegate = newValue
            self.contentView.delegate = newValue
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        self.mediaButton = UIButton(frame: CGRectMake(282, 8, 28, 28))
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.contentView = MessagesComposerTextView(frame: CGRectMake(9, 7, 214, 30))
        self.mediaButton = UIButton(frame: CGRectMake(282, 8, 25, 25))
        self.mediaButton.setImage(UIImage(named: "add.png"), forState: UIControlState.Normal)
        
        super.init(frame: frame)
        self.mediaButton.addTarget(self, action: "addMedia", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.backgroundColor = UIColorFromRGB(0xDCDCDC)
        
        self.addSubview(self.contentView)
        self.addSubview(self.mediaButton)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let left = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 9)
        self.addConstraint(left)
        
        let right = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: -97)
        self.addConstraint(right)
        
        
        let top = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 7)
        self.addConstraint(top)
        
        
        let bottom = NSLayoutConstraint(item: self.contentView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -7)
        self.addConstraint(bottom)
    }
    
    func addMedia() {
        self.delegate?.didSelectedMultipleMediaAction(true)
    }
    
}