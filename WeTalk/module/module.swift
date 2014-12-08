//
//  module.swift
//  WeTalk
//
//  Created by GoldRatio on 11/26/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

protocol Module {
    
    func key() -> String
    
    func handle(json: JSON)
}
