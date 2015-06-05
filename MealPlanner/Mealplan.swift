//
//  Mealplan.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import Foundation

class Mealplan: AnyObject {
    var days = [Day]()
    
    class Day: AnyObject {
        var name : String?
        var menus = [Menu]()
        var dayNumber : Int = 0
        var note : String?
    }
    
    class Menu: AnyObject {
        var category, title : String?
        var price : Double = 0
    }
    
    static func CreateMealplan(mensa :Mensa, callback: (Mealplan) -> Void) {
        
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
                    callback(mensaplan)
                    return
                }
            }
        }
        
        
        // Download new data
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mensa.url)
        // Url is statically set
        var task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                println("\(error.localizedDescription)")
            } else {
                // Cache this file
                if !data.writeToFile(path, atomically: false) {
                    println("Saving file failed")
                }
                
                // Parse in background and then send it to the UI
                let mensaplan = Mealplan(data: data)
                // Important UI might break otherwise
                dispatch_async(dispatch_get_main_queue(), {
                    callback(mensaplan)
                })
            }
        }
        task.resume()
    }
    
    init(data:NSData) {
        var err : NSError?
        //let options = CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value)
        //let parser = HTMLParser(data: data, encoding: NSUTF8StringEncoding, option: options, error: &err)
        let parser = GDataXMLDocument(HTMLData: data, error: &err)
        if err != nil {return}
        
        let weekdays = ["montag", "dienstag", "mittwoch", "donnerstag", "freitag"]
        for var i = 0; i < weekdays.count; i++ {
            let day = parseDay(parser, weekday:weekdays[i])
            day.dayNumber = i
            days.append(day)
        }
        /*
        let nextSuffix = "Naechste"
        for weekday in weekdays {
            if let day = parseDay(parser, weekday:weekday+nextSuffix) {
                day.dayNumber = dayNumber
                days.append(day)
            }
            dayNumber++
        }*/
    }
    
    private static let trimChars = NSCharacterSet(charactersInString: "\n\r\t ")
    private func parseDay(parser: GDataXMLDocument, weekday : String) -> Day {
        let day = Day()
        
        var err : NSError?
        let dayElem = parser.firstNodeForXPath("//div[@id=\"\(weekday)\"]", error: &err) as? GDataXMLElement
        if dayElem == nil {return day}
        
        let nameNode = parser.firstNodeForXPath("//a[@data-anchor=\"#\(weekday)\"]", error: &err)
        if let name = nameNode?.stringValue() {
            day.name = name.stringByTrimmingCharactersInSet(Mealplan.trimChars)
        }
        
        let table = dayElem!.elementsForName("table")
        if table == nil || table.count == 0 {
            // Find a message, probably mensa closed
            let node = dayElem!.firstNodeForXPath("./div[@id=\"note\"]", error: &err)
            if node != nil {
                day.note = node.stringValue()?.stringByTrimmingCharactersInSet(Mealplan.trimChars)
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
}