//
//  Utils.swift
//  StudyIn_iOS
//
//  Created by Noha Alon on 3/10/15.
//  Copyright (c) 2015 Noha Alon & Lucas David. All rights reserved.
//

import Foundation

struct Utils {
    
    // Converts a hexadecimal value to an RGB UIColor.
    static func uicolorFromHex(rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
