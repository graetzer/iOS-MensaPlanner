//
//  Globals.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

struct Globals {
    static let rwthBlue = UIColor(rgba: "#00549F")
    static let keySelectedMensa = "org.graetzer.selected_mensa"
    static let mensas = [
        Mensa(name:"Mensa Academica",
            address:"Aachen Pontwall 3",
            url:"http://www.studentenwerk-aachen.de/speiseplaene/academica-w.html"),
        Mensa(name:"Mensa Academica",
            address:"Aachen Pontwall 3",
            url:"http://www.studentenwerk-aachen.de/speiseplaene/academica-w.html"),
        Mensa(name:"Mensa Ahornstraße",
            address:"Aachen Ahornstraße 55",
            url:"http://www.studentenwerk-aachen.de/speiseplaene/ahornstrasse-w.html"),
        Mensa(name:"Mensa Bistro Templergraben",
            address:"Aachen Templergraben 55",
            url:"http://www.studentenwerk-aachen.de/speiseplaene/templergraben-w.html"),
        Mensa(name:"Mensa Bayernallee", address:"Aachen Bayernallee 9", url:"http://www.studentenwerk-aachen.de/speiseplaene/bayernallee-w.html"),
        Mensa(name:"Mensa Eupener Straße", address:"Aachen Eupener Straße 70", url:"http://www.studentenwerk-aachen.de/speiseplaene/eupenerstrasse-w.html"),
        Mensa(name:"Mensa Goethestraße",  address:"Aachen Goethestraße 3", url:"http://www.studentenwerk-aachen.de/speiseplaene/goethestrasse-w.html"),
        Mensa(name:"Mensa Vita",  address:"Aachen Helmertweg 1", url:"http://www.studentenwerk-aachen.de/speiseplaene/vita-w.html"),
        Mensa(name:"Mensa Jülich",  address:"Aachen Heinrich-Mußmann-Str. 1", url:"http://www.studentenwerk-aachen.de/speiseplaene/juelich-w.html")]
}

class Mensa {
    var name, address, url : String
    init(name :String, address :String, url :String) {
        self.name = name
        self.address = address
        self.url = url
    }
}

extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
