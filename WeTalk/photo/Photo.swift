//
//  Photo.swift
//  WeTalk
//
//  Created by GoldRatio on 12/9/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit

class Photo {
    let content: String
    
    
    var image: UIImage?
    
    var srcImageView: ImageMessageView?
    let placeholder: UIImage
    let capture: UIImage
    var index: Int = 0
    
    var firstShow: Bool
    
    init(content: String, image: UIImage?, srcImageView: ImageMessageView?, placeholder: UIImage, capture: UIImage) {
        self.content = content
        self.image = image
        self.srcImageView = srcImageView
        self.placeholder = placeholder
        self.capture = capture
        self.firstShow = true
    }
    
    lazy var url: NSURL = NSURL(string: self.content)!
    
}