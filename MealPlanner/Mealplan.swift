//
//  Mealplan.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import Foundation

public class Mealplan: AnyObject {
    var days = [Day]()
    
    /// Holds list of menus for the day
    public class Day: AnyObject {
        var menus = [Menu]()
        var date : NSDate!
        /// Should contain a message if the day has no menus e.g. the mensa is closed
        var note : String? = nil
    }
    /// Menu with price, title, category
    public class Menu: AnyObject {
        var category, title : String?
        var price : Double = 0
    }
    
    static var formatter : NSDateFormatter!
    static func CreateMealplan(mensa :Mensa, callback: (Mealplan?, NSError!) -> Void) {
        if formatter == nil {
            formatter = NSDateFormatter()
            formatter.dateFormat = "dd'.'MM'.'yyyy"
        }
        
        // Let's try to cache everything for a week
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        let path = caches.stringByAppendingPathComponent(mensa.name)
        var err : NSError?
        if let attr:NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(path, error: &err) {
            let date = attr.fileModificationDate()
            if date != nil && date!.compare(NSDate(timeIntervalSinceNow: -5*24*60*60)) == NSComparisonResult.OrderedDescending {
                // Use the cached file because it's less than a week old
                if let data = NSData(contentsOfFile: path) {
                    let mensaplan = Mealplan(data: data)
                    callback(mensaplan, nil)// Assume this is the UI thread
                    return// Exit
                }
            }
        }
        
        // Download new data with a session
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mensa.url)
        // Url is statically set
        var task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if err == nil && response.URL?.host == url?.host {
                // Do not cache this unless this is a valid file
                // don't accept redirects, for example from mops
                if !data.writeToFile(path, atomically: false) {
                    println("Saving file failed")
                }
                
                // Parse in background and then send it to the UI
                let mensaplan = Mealplan(data: data)
                // Important UI might break otherwise
                dispatch_async(dispatch_get_main_queue(), {
                    callback(mensaplan, nil)
                })
            } else {
                if error != nil {
                    println("\(error.localizedDescription)")
                }
                callback(nil, error)
            }
        }
        task.resume()
    }
    
    init(data:NSData) {
        var err : NSError?
        let parser = GDataXMLDocument(HTMLData: data, error: &err)
        if err != nil {return}
        
        let weekdays = ["montag", "dienstag", "mittwoch", "donnerstag", "freitag"]
        for weekday in weekdays {
            if let day = parseDay(parser, weekday:weekday) {
                days.append(day)
            }
        }
        let nextSuffix = "Naechste"// The HTML uses this API
        for var i = 0; i < weekdays.count; i++ {
            if let day = parseDay(parser, weekday:weekdays[i]+nextSuffix) {
                days.append(day)
            }
        }
    }
    
    private static let trimChars = NSCharacterSet(charactersInString: "\n\r\t ,")
    private func parseDay(parser: GDataXMLDocument, weekday : String) -> Day? {
        let day = Day()
        
        var err : NSError?
        let dayElem = parser.firstNodeForXPath("//div[@id=\"\(weekday)\"]", error: &err) as? GDataXMLElement
        if dayElem == nil {return nil}
        
        let nameNode = parser.firstNodeForXPath("//a[@data-anchor=\"#\(weekday)\"]", error: &err)
        if let val = nameNode?.stringValue() {
            if let v = val.rangeOfString(", ") {
                let trimmed = val.substringFromIndex(v.startIndex)
                    .stringByTrimmingCharactersInSet(Mealplan.trimChars)
                day.date = Mealplan.formatter.dateFromString(trimmed)
            }
        }
        if day.date == nil {
            return nil
        }
        
        let table = dayElem!.elementsForName("table")
        if table == nil || table.count == 0 {
            // Find a message, probably mensa closed
            let node = dayElem!.firstNodeForXPath("./div[@id=\"note\"]", error: &err)
            if let val = node.stringValue() {
                day.note = val.stringByTrimmingCharactersInSet(Mealplan.trimChars)
            }
            return day
        }
        let tbody = table[0].elementsForName("tbody")
        if tbody == nil || tbody.count == 0 {return day}
        let trs = tbody[0].elementsForName("tr")
        if trs == nil || trs.count == 0 {return day}
        
        for nTr in trs {
            let tr = nTr as! GDataXMLElement
            
            // Parse menu entries
            let menu = Menu()
            let tds = tr.elementsForName("td")
            if tds == nil {continue}
            for nTd in tds {
                let td = nTd as! GDataXMLElement
                
                let type = td.attributeForName("class")?.stringValue()
                if type == nil {continue}
                switch(type!) {
                    case "category":
                        menu.category = td.stringValue()?.stringByTrimmingCharactersInSet(Mealplan.trimChars)
                        break
                    case "menue", "extra":
                        menu.title = td.stringValue()?.stringByTrimmingCharactersInSet(Mealplan.trimChars)
                        break
                    case "price":
                        var contents = td.stringValue()
                        contents = contents?.stringByReplacingOccurrencesOfString("€", withString: "")
                        contents = contents?.stringByReplacingOccurrencesOfString(",", withString: ".")
                        contents = contents?.stringByTrimmingCharactersInSet(Mealplan.trimChars)
                        menu.price = (contents as NSString).doubleValue
                        break
                    default:break
                }
            }
            day.menus.append(menu)
        }
        
        return day
    }
    
    /// Try to find the best fitting day entry for this day index hhh
    ///
    /// :param:  weekday Should be the day of the week, 0-5 or 8-13
    public func dayForIndex(weekday : Int) -> Day? {
        let cal = NSCalendar.currentCalendar()
        let flags : NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay
        let todayComps = cal.components(flags, fromDate: NSDate())
        
        if let today = cal.dateFromComponents(todayComps) {// Get a date object for today without time
            let diff = NSTimeInterval(weekday - Globals.currentWeekdayIndex()) // Difference in days
            let lastDay = NSDate(timeInterval: -diff * 24 * 60 * 60, sinceDate: today)

            // Select best day
            for day in self.days {
                if lastDay.isEqualToDate(day.date) {
                    return day
                }
            }
        }
        return nil
    }
}