//
//  ChatViewCell.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

class ChatViewCell: UITableViewCell
{
    let swImageView: SWWebImageView
    let recentLabel: UILabel
    let timeLabel: UILabel
    let countLabel: BadgeView
    
    required init(coder aDecoder: NSCoder) {
        swImageView = SWWebImageView(frame: CGRectMake(12, 10, 35, 35))
        swImageView.layer.masksToBounds = true
        recentLabel = UILabel(frame: CGRectMake(60, 32, 200, 15))
        timeLabel = UILabel(frame: CGRectMake(250, 10, 200, 14))
        countLabel = BadgeView(frame: CGRectMake(250, 10, 200, 14))
        super.init(coder: aDecoder)
        self.addSubview(swImageView)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        swImageView = SWWebImageView(frame: CGRectMake(10, 10, 35, 35))
        swImageView.layer.masksToBounds = true
        
        recentLabel = UILabel(frame: CGRectMake(60, 30, 200, 15))
        recentLabel.textColor = UIColorFromRGB(0x666666)
        
        recentLabel.font = UIFont.systemFontOfSize(12)
        
        timeLabel = UILabel(frame: CGRectMake(230, 10, 70, 14))
        timeLabel.textColor = UIColorFromRGB(0x999999)
        timeLabel.font = UIFont.systemFontOfSize(10)
        timeLabel.textAlignment = NSTextAlignment.Right
        
        countLabel = BadgeView(frame: CGRectMake(250, 30, 50, 15))
        countLabel.padding = 6
        countLabel.color = UIColorFromRGB(0xFF0000)
        countLabel.textColor = UIColor.whiteColor()
        countLabel.font = UIFont .systemFontOfSize(12)
        countLabel.align = NSTextAlignment.Right
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.textColor = UIColorFromRGB(0xFF6C26)
        self.textLabel?.font = UIFont.systemFontOfSize(13)
        self.addSubview(swImageView)
        self.addSubview(recentLabel)
        self.addSubview(timeLabel)
        self.addSubview(countLabel)
    }
    
    func setAvatar(url: String) {
        let nsUrl = NSURL(string: url)
        //self.swImageView.sw_setImageWithURL(nsUrl, placeholderImage: UIImage(named: "user_placeholder@2x.png"))
        self.swImageView.setImage(nsUrl!, placeholderImage: UIImage(named: "placeholder@2x.png")!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.frame
        self.textLabel?.frame = CGRectMake(60, 10, 200, 18)
        self.swImageView.frame = CGRectMake(12, 10, 35, 35)
    }
}