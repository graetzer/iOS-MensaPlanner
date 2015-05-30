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
        
        /*
        private Pattern datePattern = Pattern.compile("([0-9][0-9])\\.([0-9][0-9])\\.([0-9][0-9][0-9][0-9])");
        
        public boolean IsToday() {
        Calendar calendar = Calendar.getInstance();
        String test = String.format("%02d.%02d.%04d", calendar.get(Calendar.DAY_OF_MONTH), calendar.get(Calendar.MONTH)+1, calendar.get(Calendar.YEAR));
        Log.d(TAG, test);
        return name.contains(test);
        }
        */
    }
    
    class Menu: AnyObject {
        var category, title : String?
        var price : Double = 0
    }
    
    private static var mealplanMap = Dictionary<String, Mealplan>()
    static func CreateMealplan(mensa :Mensa, callback: (Mealplan) -> Void) {
        if let mealplan = self.mealplanMap[mensa.name] {
            callback(mealplan)
            return
        }
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mensa.url)
        // Url is statically set
        var task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                println("\(error.localizedDescription)")
                return
            }
            let mensaplan = Mealplan(data: data)
            self.mealplanMap[mensa.name] = mensaplan
            callback(mensaplan)
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
        let nextSuffix = "Naechste"
        for weekday in weekdays {
            if let day = parseDay(parser, weekday:weekday) {
                days.append(day)
            }
        }
        for weekday in weekdays {
            if let day = parseDay(parser, weekday:weekday+nextSuffix) {
                days.append(day)
            }
        }
    }
    
    private let trimChars = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    private func parseDay(parser: GDataXMLDocument, weekday : String) -> Day? {
        var err : NSError?
        let node = parser.firstNodeForXPath("//div[@id=\"\(weekday)\"]", error: &err)
        if node == nil {return nil}
        
        let day = Day()
        let nameNode = parser.firstNodeForXPath("//a[@data-anchor=\"#\(weekday)\"]", error: &err)
        if nameNode != nil {
            day.name = nameNode.stringValue().stringByTrimmingCharactersInSet(trimChars)
        }
        let elem = node as! GDataXMLElement
        
        // Every table row is a menu
        let dayElem = parser.firstNodeForXPath("//div[@id=\"\(weekday)\"]", error: &err) as? GDataXMLElement
        if dayElem == nil {return nil}
        let table = dayElem!.elementsForName("table")
        if table == nil || table.count == 0 {return nil}
        let tbody = table[0].elementsForName("tbody")
        if tbody == nil || tbody.count == 0 {return nil}
        let trs = tbody[0].elementsForName("tr")
        if trs == nil || trs.count == 0 {return nil}
        
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
                        menu.category = td.stringValue()?.stringByTrimmingCharactersInSet(trimChars)
                        break
                    case "menue", "extra":
                        menu.title = td.stringValue()?.stringByTrimmingCharactersInSet(trimChars)
                        break
                    case "price":
                        var contents = td.stringValue()
                        contents = contents?.stringByReplacingOccurrencesOfString("€", withString: "")
                        contents = contents?.stringByReplacingOccurrencesOfString(",", withString: ".")
                        contents = contents?.stringByTrimmingCharactersInSet(trimChars)
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