//
//  Globals.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

public struct Globals {
    static let rwthBlue = UIColor(rgba: "#00549F")
    static let keySelectedMensa = "org.graetzer.selected_mensa"
    static let mensas = [
        Mensa(name:"Mensa Academica",
            address:"Aachen Pontwall 3",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/academica-w.html"),
        Mensa(name:"Ahorn55",
            address:"Aachen Ahornstraße 55",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/ahornstrasse-w.html"),
        Mensa(name:"Bistro Templergraben",
            address:"Aachen Templergraben 55",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/templergraben-w.html"),
        Mensa(name:"Forum Cafete",
            address:"Aachen Eilfschornsteinstraße 15",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/forum-w.html"),
        Mensa(name:"Mensa Bayernallee",
            address:"Aachen Bayernallee 9",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/bayernallee-w.html"),
        Mensa(name:"Mensa Eupener Straße",
            address:"Aachen Eupener Straße 70",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/eupenerstrasse-w.html"),
        Mensa(name:"Gastro Goethe",
            address:"Aachen Goethestraße 3",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/goethestrasse-w.html"),
        Mensa(name:"Mensa Vita",
            address:"Aachen Helmertweg 1",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/vita-w.html"),
        Mensa(name:"Mensa Jülich",
            address:"Aachen Heinrich-Mußmann-Str. 1",
            url:"http://www.studierendenwerk-aachen.de/speiseplaene/juelich-w.html")]
    
    static func enabledMensas() -> [Mensa]{
        var array = mensas
        // per default non are disabled
        if let disabled:NSArray = disabledMensaNames() {
            for name in disabled {
                for var i = 0; i < array.count; i++ {
                    if array[i].name == name as! String {
                        array.removeAtIndex(i)
                        i--
                    }
                }
            }
        }
        return array
    }
    
    static func disabledMensaNames() -> NSArray? {
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let path = (caches as NSString).stringByAppendingPathComponent("_disabled.plist")
        return NSArray(contentsOfFile: path)
    }
    
    static func setDisabledMensas(names :NSArray) {
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let path = (caches as NSString).stringByAppendingPathComponent("_disabled.plist")
        names.writeToFile(path, atomically: false)
    }
    
    private static let keySelectedMensaIndex = "SelectedMensaIndex"
    static var selectedMensa : Mensa {
        get {
            let i = NSUserDefaults.standardUserDefaults().integerForKey(keySelectedMensaIndex)
            return mensas[min(max(i, 0), mensas.count)]
        }
        
        set {
            if let i = Globals.mensas.indexOf(newValue) {
                NSUserDefaults.standardUserDefaults().setInteger(i, forKey: keySelectedMensaIndex)
            }
        }
    }
    
    /// Current weekday returns 0-6 for each weekday starting with monday
    static func currentWeekday() -> Int {
        let cal = NSCalendar.currentCalendar()
        cal.firstWeekday = 2 // Monday, NSCalendar starts with saturdays
        return cal.ordinalityOfUnit(.Weekday,
            inUnit:.WeekOfMonth, forDate: NSDate()) - 1
    }
    
    static func isWeekend() -> Bool {
        let weekday = currentWeekday()
        return weekday == 5 || weekday == 6
    }
    
    /// Index of the current or next woeking day, uses the current calendar of the user
    /// Will skip weekends and return 0 (for monday) if the current weekday is a saturday or monday
    ///
    /// - returns: 0-4 depending on the current day, starting at monday with 0
    static func currentWorkdayIndex() -> Int {
        let weekday = currentWeekday()
        return weekday < 5 ? weekday : 0// Skip to monday
    }
}

public class Mensa: Equatable {
    var name, address, url : String
    init(name :String, address :String, url :String) {
        self.name = name
        self.address = address
        self.url = url
    }
}
public func ==(lhs: Mensa, rhs: Mensa) -> Bool {
    return lhs.name == rhs.name
}

extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (hex.characters.count) {
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
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
