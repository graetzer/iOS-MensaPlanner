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
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Backward, .Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            if mealplan != nil {
                handler(mealplan!.days.first?.date)
            } else {
                handler(NSDate())
            }
        }
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            if mealplan != nil {
                handler(mealplan!.days.last?.date)
            } else {
                handler(NSDate())
            }
        }
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication,
        withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Get the complication data
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            
            let weekday = Globals.currentWorkdayIndex()
            if let day = mealplan?.dayForIndex(weekday) {
                if let template = self.createTemplate(complication, mensa: mensa, day: day) {
                    let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
                    handler(entry) // Pass the timeline entry back to ClockKit.
                } else {
                    handler(nil)
                }
            }
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void)
    {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            var entries = [CLKComplicationTimelineEntry]()
            if let plan = mealplan {
                for day in plan.days {
                    if date.compare(day.date) == .OrderedDescending {
                        if let template = self.createTemplate(complication, mensa: mensa, day: day) {
                            let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
                            entries.append(entry)
                        }
                    }
                }
            }
            handler(entries)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: ([CLKComplicationTimelineEntry]?) -> Void) {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            var entries = [CLKComplicationTimelineEntry]()
            if let plan = mealplan {
                for day in plan.days {
                    if date.compare(day.date) == .OrderedAscending {
                        if let template = self.createTemplate(complication, mensa: mensa, day: day) {
                            let entry = CLKComplicationTimelineEntry(date: day.date, complicationTemplate: template)
                            entries.append(entry)
                        }
                    }
                }
            }
            handler(entries)
        }
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            let weekday = Globals.currentWorkdayIndex()
            var day = mealplan?.dayForIndex(weekday)
            if day == nil {
                day = Mealplan.Day()
                day!.note = NSLocalizedString("Meal of the Day", comment: "Menu placeholder")
            }
            let template = self.createTemplate(complication, mensa: mensa, day: day!)
            handler(template)
        }
    }
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Update every week
        handler(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7.0 / 2.0))
    }
    
    func requestedUpdateDidBegin() {
        let mensa = Globals.selectedMensa
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            // Upload as soon as the cache is gone
            if mealplan != nil && mealplan!.isCached == false {
                let complicationServer = CLKComplicationServer.sharedInstance()
                for complication in complicationServer.activeComplications {
                    complicationServer.reloadTimelineForComplication(complication)
                }
            }
        }
    }
    
    private func createTemplate(complication : CLKComplication, mensa : Mensa, day : Mealplan.Day) -> CLKComplicationTemplate? {
        var long = ""
        var short : String?
        if let note = day.note {
            long = note
        } else {
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
                long = title
            }
        }
        short = long.componentsSeparatedByString(" ").first
        let provider = CLKSimpleTextProvider(text: long, shortText: short)
        
        // Create the template and timeline entry.
        if complication.family == .ModularSmall {
            let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
            textTemplate.textProvider = provider
            return textTemplate
        } else if complication.family == .ModularLarge {
            let textTemplate = CLKComplicationTemplateModularLargeTallBody()
            textTemplate.headerTextProvider = CLKSimpleTextProvider(text: mensa.name)
            textTemplate.bodyTextProvider = provider
            return textTemplate
        } else if complication.family == .UtilitarianSmall {
            let textTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            textTemplate.textProvider = provider
            return textTemplate
        } else if complication.family == .UtilitarianLarge {
            let textTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            textTemplate.textProvider = provider
            return textTemplate
        }
        return nil
    }
}
