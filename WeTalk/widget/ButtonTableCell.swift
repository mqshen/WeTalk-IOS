//
//  ButtonTableCell.swift
//  WeTalk
//
//  Created by GoldRatio on 12/30/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

protocol TableButtonDelegate
{
    func doAccept(cell: UITableViewCell)
    func doReject(cell: UITableViewCell)
}

class ButtonTableCell: UITableViewCell
{
    var delegate: TableButtonDelegate?
    
    let swImageView: SWWebImageView
    let acceptButton: UIButton
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        acceptButton = UIButton(frame: CGRectMake(255, 12.5, 50, 30))
        acceptButton.layer.masksToBounds = true
        acceptButton.layer.cornerRadius = 4
        
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        acceptButton.addTarget(self, action: "doAccept", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(swImageView)
        self.addSubview(acceptButton)
    }
    
    func setAvatar(url: String) {
        if let nsUrl = NSURL(string: url)? {
            self.swImageView.setImage(nsUrl, placeholderImage: UIImage(named: "placeholder@2x.png")!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        self.textLabel?.frame = CGRectMake(53, 0, 200, frame.size.height)
        self.swImageView.frame = CGRectMake(10, 10, 35, 35)
    }
    
    func doAccept() {
        if let delegate = self.delegate? {
            delegate.doAccept(self)
        }
    }
    
    func doReject() {
        if let delegate = self.delegate? {
            delegate.doReject(self)
        }
    }
    
    
    func setAccept(flag: Int) {
        if flag == 0 {
            acceptButton.setTitle("接受",forState: UIControlState.Normal)
            acceptButton.backgroundColor = UIColorFromRGB(0x33BC03)
        }
        else {
            acceptButton.userInteractionEnabled = false
            acceptButton.setTitle("接受",forState: UIControlState.Normal)
            acceptButton.backgroundColor = UIColor.clearColor()
            acceptButton.setTitleColor(UIColor.grayColor(), forState:UIControlState.Normal)
        }
    }
}