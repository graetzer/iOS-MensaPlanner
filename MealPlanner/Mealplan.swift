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
    let isCached : Bool
    
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
        var isExtra = false
    }
    
    public static func cachedMensaPath(mensa :Mensa) -> (Bool, String) {
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] 
        let path = (caches as NSString).stringByAppendingPathComponent(mensa.name)
        let fmgr = NSFileManager.defaultManager()
        if fmgr.fileExistsAtPath(path) {
            do {
                let attr:NSDictionary = try fmgr.attributesOfItemAtPath(path)
                let date = attr.fileModificationDate()
                let cutoff = NSDate(timeIntervalSinceNow: -5*24*60*60)// 5 days
                let usable = date != nil ? cutoff.compare(date!) == .OrderedAscending : false
                return (usable, path)
            } catch let error as NSError {
                print("error reading file: \(error.localizedDescription)")
            }
        }
        return (false, path)
    }
    
    static func LoadMealplan(mensa :Mensa, completionHandler: (Mealplan?, NSError?) -> Void) {
        
        let (usable, path) = cachedMensaPath(mensa)
        if usable {
            if let data = NSData(contentsOfFile: path) {
                let mensaplan = Mealplan(data: data, isCached: true)
                if mensaplan.days.count > 0 {// Only use this if it seems ok
                    completionHandler(mensaplan, nil)// Assume this is the UI thread
                    return// Exit
                }
            }
        }
        
        // Download new data with a session
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mensa.url)!
        // Url is statically set
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            var mealplan : Mealplan?
            if error == nil && data != nil {
                
                // Parse in background and then send it to the UI
                mealplan = Mealplan(data: data!)
                if mealplan!.days.count > 0 {
                    data!.writeToFile(path, atomically: false)
                }
            }
            
            // Important UI might break otherwise
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    print("\(error!.localizedDescription)")
                }
                completionHandler(mealplan, error)
            })
        }
        task.resume()// boom!
    }
    
    init(data:NSData, isCached:Bool = false) {
        self.isCached = isCached
        
        var err : NSError?
        let parser: GDataXMLDocument!
        do {
            parser = try GDataXMLDocument(HTMLData: data)
        } catch let error as NSError {
            err = error
            parser = nil
        }
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
        
        days.sortInPlace({$0.date.compare($1.date) == .OrderedAscending})
    }
    
    // Static for speed
    private static let trimChars = NSCharacterSet(charactersInString: "\n\r\t ,")
    static var formatter : NSDateFormatter! = nil
    private func parseDay(parser: GDataXMLDocument, weekday : String) -> Day? {
        if Mealplan.formatter == nil {
            Mealplan.formatter = NSDateFormatter()
            Mealplan.formatter.dateFormat = "dd'.'MM'.'yyyy"
        }
        
        let dayElem : GDataXMLElement?
        do {
            dayElem = try parser.firstNodeForXPath("//div[@id=\"\(weekday)\"]") as? GDataXMLElement
        } catch {
            return nil
        }
        
        let nameNode: GDataXMLNode?
        do {
            nameNode = try parser.firstNodeForXPath("//a[@data-anchor=\"#\(weekday)\"]")
        } catch {
            return nil
        }
        
        let day = Day()// the resulting  day object
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
        
        if let tables = dayElem?.elementsForName("table") {
            for table in tables {
                day.menus += parseMenuTable(table as! GDataXMLElement)
            }
        } else {
            // Find a message, probably mensa closed
            let node: GDataXMLNode?
            do {
                node = try dayElem!.firstNodeForXPath("./div[@id=\"note\"]")
            } catch {
                node = nil
            }
            if let val = node?.stringValue() {
                day.note = val.stringByTrimmingCharactersInSet(Mealplan.trimChars)
            }
            return day
        }
        
        return day
    }
    
    private func parseMenuTable(table : GDataXMLElement) -> [Menu] {
        let tbody = table.elementsForName("tbody")
        if tbody == nil || tbody.count == 0 {return []}
        let trs = tbody[0].elementsForName("tr")
        if trs == nil || trs.count == 0 {return []}
        
        var menus = [Menu]()
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
            menus.append(menu)
        }
        return menus
    }
    
    /** 
    Try to find the best fitting day entry for this weekday index
    If weekday is 5 or 6 (saturday or sunday) it will skip to monday.
    Similary if today is a saturday / sunday and weekday is a day during the week, we skip to the next week
    
    - parameter  weekday: Should be the day of the week, 0-5 or 8-13
    */
    public func dayForIndex(weekday : Int) -> Day? {
        if Globals.isWeekend() && weekday < 5 {
            return dayForIndex(weekday + 7) // Skip to next week
        }
        
        // Try to produce a date object without time
        let cal = NSCalendar.currentCalendar()
        let flags : NSCalendarUnit = [.Year, .Month, .Day]
        let todayComps = cal.components(flags, fromDate: NSDate())
        
        // Get a date object for today without time
        if let todayDate = cal.dateFromComponents(todayComps) {
            // Difference in days
            let diff = NSTimeInterval(weekday - Globals.currentWeekday())
            let lastDay = NSDate(timeInterval: diff * 24 * 60 * 60, sinceDate: todayDate)

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