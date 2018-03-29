//
//  Mealplan.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import Foundation

public class Mealplan {
    var days = [Day]()
    let isCached : Bool
    
    /// Holds list of menus for the day
    public class Day {
        var menus = [Menu]()
        var date : Date!
        /// Should contain a message if the day has no menus e.g. the mensa is closed
//        var note : String? = nil
    }
    /// Menu with price, title, category
    public class Menu {
        var category, title : String?
        var price : Double = 0
        var isExtra = false
    }
    
  public static func cachedMensaPath(mensa :Mensa) -> (Bool, String) {
    let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    let path = (caches as NSString).appendingPathComponent(mensa.name)
    let fmgr = FileManager.default
    if fmgr.fileExists(atPath: path) {
      do {
        let attr:[FileAttributeKey:Any] = try fmgr.attributesOfItem(atPath: path)
        let date = attr[FileAttributeKey.modificationDate] as? NSDate
        let cutoff = Date(timeIntervalSinceNow: -5*24*60*60)// 5 days
        let usable = date != nil ? cutoff.compare(date! as Date) == .orderedAscending : false
        return (usable, path)
      } catch let error as NSError {
        print("error reading file: \(error.localizedDescription)")
      }
    }
    return (false, path)
  }
    
  static func LoadMealplan(mensa :Mensa, completionHandler: @escaping (Mealplan?, Error?) -> Void) {
        
      let (usable, path) = cachedMensaPath(mensa: mensa)
        if usable {
          do {
            let data = try Data(contentsOf: URL(fileURLWithPath:path))
            let mensaplan = Mealplan(data: data, isCached: true)
            if mensaplan.days.count > 0 {// Only use this if it seems ok
                completionHandler(mensaplan, nil)// Assume this is the UI thread
                return// Exit
            }
          } catch {
                print("Unexpected error: \(error).")
          }
        }
        
        // Download new data with a session
      let session = URLSession.shared
        let url = URL(string: mensa.url)!
        // Url is statically set
        let task = session.dataTask(with:url, completionHandler: { (data, response, error) -> Void in
            var mealplan : Mealplan?
            if error == nil && data != nil {
                
                // Parse in background and then send it to the UI
                mealplan = Mealplan(data: data!)
                if mealplan!.days.count > 0 {
                  do {
                    try data?.write(to: URL(fileURLWithPath: path))
                  } catch {
                    print("Unexpected error: \(error).")
                  }
                }
            }
          
          // Important UI might break otherwise
          DispatchQueue.main.async(execute:{
            if error != nil {
              print("\(error!.localizedDescription)")
            }
            completionHandler(mealplan, error)
          })
        })
        task.resume()// boom!
    }
    
    init(data:Data, isCached:Bool = false) {
        self.isCached = isCached
        
        var err : NSError?
        let parser: GDataXMLDocument!
        do {
          parser = try GDataXMLDocument(htmlData: data)
        } catch let error as NSError {
            err = error
            parser = nil
        }
        if err != nil {return}
        
        let weekdays = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
        for weekday in weekdays {
          if let day = parseDay(parser: parser, weekday:weekday) {
                days.append(day)
            }
        }
        let nextSuffix = "Naechste"// The HTML uses this API
        for i in 0..<weekdays.count {
          if let day = parseDay(parser: parser, weekday:weekdays[i]+nextSuffix) {
                days.append(day)
            }
        }
        
      days.sort(by: {$0.date.compare($1.date) == .orderedAscending})
    }
    
    // Static for speed
    private static let trimChars = CharacterSet(charactersIn: "\n\r\t ,")
  static var formatter : DateFormatter! = nil
    private func parseDay(parser: GDataXMLDocument, weekday : String) -> Day? {
        if Mealplan.formatter == nil {
            Mealplan.formatter = DateFormatter()
            Mealplan.formatter.dateFormat = "dd'.'MM'.'yyyy"
        }
        
        let dayElem : GDataXMLElement?
        do {
          dayElem = try parser.firstNode(forXPath: "//div[@id=\"\(weekday)\"]") as? GDataXMLElement
        } catch {
            return nil
        }
        
        let nameNode: GDataXMLNode?
        do {
          nameNode = try parser.firstNode(forXPath: "//a[@data-anchor=\"#\(weekday.lowercased())\"]")
        } catch {
            return nil
        }
        
        let day = Day()// the resulting  day object
        if let val = nameNode?.stringValue() {
            if let v = val.range(of: ", ") {
                let trimmed = val[v.lowerBound...]// .substringFromIndex(v.startIndex)
                    .trimmingCharacters(in: Mealplan.trimChars)
              day.date = Mealplan.formatter.date(from: trimmed)
            }
        }
        if day.date == nil {
            return nil
        }
        
      if let tables = dayElem?.elements(forName: "table") {
            for table in tables {
              day.menus += parseMenuTable(table: table)
            }
        }
//        else {
//            // Find a message, probably mensa closed
//            let node: GDataXMLNode?
//            do {
//                node = try dayElem!.firstNodeForXPath("./div[@id=\"note\"]")
//            } catch {
//                node = nil
//            }
//            if let val = node?.stringValue() {
//                day.note = val.stringByTrimmingCharactersInSet(Mealplan.trimChars)
//            }
//            return day
//        }
        
        return day
    }
    
    private func parseMenuTable(table : GDataXMLElement) -> [Menu] {
      let tbody = table.elements(forName: "tbody")
      if tbody == nil || tbody!.count == 0 {return []}
      let trs = tbody![0].elements(forName: "tr")
      if trs == nil || trs!.count == 0 {return []}
        
        var menus = [Menu]()
        for nTr in trs! {
            let tr = nTr as? GDataXMLElement
            if let tds = tr?.children() {
                for td in tds where td.kind() == .xmlElementKind && td.localName() == "td" {
                    let items = (td as? GDataXMLElement)?.children()
                    if items == nil {continue}

                    // Parse menu entries
                    let menu = Menu()
                    for node in items! where node.kind() == .xmlElementKind {
                        let el = node as! GDataXMLElement
                      if let type = el.attribute(forName: "class")?.stringValue() {
                            if type.contains("menue-category") {
                              menu.category = self.textFromElement(el: el)
                            } else if type.contains("menue-desc") {
                              menu.title = self.textFromElement(el: el)
                            } else if type.contains("menue-price") {
                                var contents = el.stringValue()
                                contents = contents?.replacingOccurrences(of: "€", with: "")
                                contents = contents?.replacingOccurrences(of: ",", with: ".")
                                contents = contents?.trimmingCharacters(in: Mealplan.trimChars)
                                if let s = contents as NSString? {
                                    menu.price = s.doubleValue
                                }
                            }
                        }
                    }
                    menus.append(menu)
                }
            }
        }
        return menus
    }
    
    /// Get the text from this element but ignore meaningless annotations in <sup> tags
    private func textFromElement(el : GDataXMLElement) -> String? {
        var buffer : String = ""
        for node in el.children() {
            if node.kind() == .xmlTextKind {
                buffer += node.stringValue() + " "
            }/* else if node.kind() == .XMLElementKind {
                var text = node.stringValue()
                if text
            }*/
        }
        // remove unnecessary blanks and weird formatting leftovers
        buffer = buffer.replacingOccurrences(of: "  ", with: "")
        buffer = buffer.replacingOccurrences(of: " , ", with: ", ")
        return buffer.trimmingCharacters(in: Mealplan.trimChars)
    }
    
    /** 
    Try to find the best fitting day entry for this weekday index
    If weekday is 5 or 6 (saturday or sunday) it will skip to monday.
    Similary if today is a saturday / sunday and weekday is a day during the week, we skip to the next week
    
    - parameter  weekday: Should be the day of the week, 0-5 or 8-13
    */
    public func dayForIndex(weekday : Int) -> Day? {
        if weekday < 5 && Globals.isWeekend() {
          return dayForIndex(weekday: weekday + 7) // Skip to next week
        }
        
        // Try to produce a date object with time 0:00
      let cal = Calendar.current
      let flags : Set<Calendar.Component> = [.year, .month, .day]
      let todayComps = cal.dateComponents(flags, from: Date())
      
        // Get a date object for today without time
        if let todayDate = cal.date(from: todayComps) {
            // Difference in days
            let diff = TimeInterval(weekday - Globals.currentWeekday())
          let weekdayDate = Date(timeInterval: diff * 24 * 60 * 60, since: todayDate)

            // Select best day
            for day in self.days {
                if cal.isDate(day.date, inSameDayAs: weekdayDate) {
                    return day
                }
            }
        }
        return nil
    }
}
