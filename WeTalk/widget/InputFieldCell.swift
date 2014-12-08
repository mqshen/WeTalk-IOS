//
//  InputFieldCell.swift
//  WeTalk
//
//  Created by GoldRatio on 11/25/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class InputFieldCell: UITableViewCell, UITextFieldDelegate {
    
    let input: UITextField
    
    
    required init(coder aDecoder: NSCoder) {
        input = UITextField(frame: CGRectMake(250, 10, 200, 14))
        super.init(coder: aDecoder)
        self.addSubview(input)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        input = UITextField(frame: CGRectMake(250, 10, 200, 14))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(input)
        input.delegate = self
    }
    
    
    override func layoutSubviews() {
        let frame = self.frame
        self.textLabel?.frame = CGRectMake(10, 0, 60, frame.size.height)
        self.input.frame = CGRectMake(75, 0, frame.size.width - 80, frame.size.height)
    }
    
}