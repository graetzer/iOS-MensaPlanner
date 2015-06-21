//
//  GlanceController.swift
//  MensaPlanner WatchKit Extension
//
//  Created by Simon Grätzer on 28.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import WatchKit
import Foundation


class  GlanceController: WKInterfaceController {
    @IBOutlet weak var mensaLabel: WKInterfaceLabel!
    @IBOutlet weak var menuLabel: WKInterfaceLabel!
    @IBOutlet weak var categoryLabel: WKInterfaceLabel!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    // Key for the
    static let userActivityType = "org.graetzer.MensaPlanner.openMensa"
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let mensa = Globals.selectedMensa
        // Handoff to the main app
        if let url = NSURL(string: mensa.url) {
            self.updateUserActivity(GlanceController.userActivityType, userInfo: nil, webpageURL: url)
        }
        
        mensaLabel.setText(mensa.name)
        // Ideally this is cached and just loaded from the phone or something
        Mealplan.CreateMealplan(mensa, callback: {(mealplan, error) in
            self.updateUI(mealplan)
        })
    }
    
    private func updateUI(mealplan : Mealplan?) {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        let weekday = Globals.currentWorkdayIndex()
        if let day = mealplan?.dayForIndex(weekday) {
            
            if let note = day.note {
                self.menuLabel.setText(note)
                self.categoryLabel.setText(note)
                self.priceLabel.setText("")
            } else {
                // Try to find todays recommendated menu
                // TODO: Let the user choose what kind of menu he would like to see
                var sel = day.menus.last
                for menu in day.menus {
                    if menu.price == 2.60 {
                        sel = menu
                        break
                    }
                }
                if sel != nil {
                    self.menuLabel.setText(sel!.title)
                    self.categoryLabel.setText(sel!.category)
                    self.priceLabel.setText(numberFormatter.stringFromNumber(sel!.price))
                }
            }
        }
    }
}
