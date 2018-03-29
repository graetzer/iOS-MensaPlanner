//
//  CompliationController.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 26.02.16.
//  Copyright © 2016 Simon Grätzer. All rights reserved.
//

import WatchKit
import ClockKit

@objc
class CompliationController: NSObject, CLKComplicationDataSource {
  private let dateFormatter = DateFormatter()
  
  override init() {
    dateFormatter.dateFormat = "ccc"
  }
  
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    handler([.backward, .forward])
  }
  
  func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      if mealplan != nil {
        handler(mealplan!.days.first?.date)
      } else {
        handler(Date())
      }
    }
  }
  
  func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      if mealplan != nil {
        handler(mealplan!.days.last?.date)
      } else {
        handler(Date())
      }
    }
  }
  
  func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
    handler(.showOnLockScreen)
  }
  
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    // Get the complication data
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      
      let weekday = Globals.currentWorkdayIndex()
      if let day = mealplan?.dayForIndex(weekday: weekday) {
        if let template = self.createTemplate(complication: complication, mensa: mensa, day: day) {
          let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
          handler(entry) // Pass the timeline entry back to ClockKit.
        } else {
          handler(nil)
        }
      }
    }
  }
  
  func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      var entries = [CLKComplicationTimelineEntry]()
      if let plan = mealplan {
        for day in plan.days {
          if date.compare(day.date) == .orderedDescending {
            if let template = self.createTemplate(complication: complication, mensa: mensa, day: day) {
              let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
              entries.append(entry)
            }
          }
        }
      }
      handler(entries)
    }
  }
  
  func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      var entries = [CLKComplicationTimelineEntry]()
      if let plan = mealplan {
        for day in plan.days {
          if date.compare(day.date) == .orderedAscending {
            if let template = self.createTemplate(complication: complication, mensa: mensa, day: day) {
              let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
              entries.append(entry)
            }
          }
        }
      }
      handler(entries)
    }
  }
  
  func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      let weekday = Globals.currentWorkdayIndex()
      var day = mealplan?.dayForIndex(weekday: weekday)
      if day == nil {
        day = Mealplan.Day()
        let menu = Mealplan.Menu()
        menu.title = NSLocalizedString("Meal of the Day", comment: "Menu placeholder")
        day!.menus.append(menu)
        //                day!.note = NSLocalizedString("Meal of the Day", comment: "Menu placeholder")
      }
      let template = self.createTemplate(complication: complication, mensa: mensa, day: day!)
      handler(template)
    }
  }
  
  func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
    // Update every week
    handler(Date(timeIntervalSinceNow: 60.0 * 60.0 * 24.0 * 7.0 / 2.0))
  }
  
  func requestedUpdateDidBegin() {
    let mensa = Globals.selectedMensa
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      // Upload as soon as the cache is gone
      if mealplan != nil {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let complications = complicationServer.activeComplications {
          for complication in complications {
            complicationServer.reloadTimeline(for: complication)
          }
        }
      }
    }
  }
  
  private func createTemplate(complication : CLKComplication, mensa : Mensa, day : Mealplan.Day) -> CLKComplicationTemplate? {
    var longtext : String = ""
    //        if let note = day.note {
    //            long = note
    //        } else {
    // Try to find todays recommendated menu
    // TODO: Let the user choose what kind of menu he would like to see
    var sel : Mealplan.Menu? = day.menus.last
    for menu in day.menus {
      if menu.price == 2.60 {
        sel = menu
        
        break
      }
    }
    if let title = sel?.title {
      longtext = title
    }
    //        }
    
    
    // Some ugly shortening of the desciptions
    let components = longtext.split(separator: " ")
    var short = components.first
    if components.count >= 2 {
      if components.count >= 3
        && components[2].count > components[1].count {
        longtext = "\(components[0]) \(components[2])"// skip vom "XXX vom YYY"
      } else {
        longtext = "\(components[0]) \(components[1])"
      }
      if components[1].count > components[0].count {
        short = components[1]
      }
    }
    
    let shortTxt = String(describing: short)
    let wd = dateFormatter.string(from: day.date)
    // Create the template, depending on the format with the weekday
    if complication.family == .modularLarge {
      let name = mensa.name.replacingOccurrences(of: "Mensa ", with: "")
      let textTemplate = CLKComplicationTemplateModularLargeStandardBody()
      textTemplate.headerTextProvider = CLKSimpleTextProvider(text: name)
      textTemplate.body1TextProvider = CLKSimpleTextProvider(text: "\(wd): \(longtext)", shortText: shortTxt)
      return textTemplate
    } else if complication.family == .utilitarianSmall {
      let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
      textTemplate.textProvider = CLKSimpleTextProvider(text: longtext, shortText: shortTxt)
      return textTemplate
    } else if complication.family == .utilitarianLarge {
      let textTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
      textTemplate.textProvider = CLKSimpleTextProvider(text: "\(wd): \(longtext)", shortText: shortTxt)
      return textTemplate
    }
    return nil
  }
}
