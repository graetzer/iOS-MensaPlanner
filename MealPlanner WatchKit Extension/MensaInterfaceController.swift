//
//  MensaInterfaceController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 28.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import WatchKit
import Foundation


class MensaInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        let mensa = context as! Mensa
        
        let name = mensa.name.stringByReplacingOccurrencesOfString("Mensa ", withString: "")
        self.setTitle(name)
        Mealplan.LoadMealplan(mensa) {(mealplan, error) in
            if mealplan == nil {
                let nodata = NSLocalizedString("No Data Found", comment: "empty mealplan message")
                self.setTitle(nodata)
            }
            
            // Select best day
            let weekday = Globals.currentWorkdayIndex()
            if let menus = mealplan?.dayForIndex(weekday)?.menus {
                self.table.setNumberOfRows(menus.count, withRowType: "MenusRowType")
                for i in 0..<menus.count {
                    let row = self.table.rowControllerAtIndex(i) as! MenusRowType
                    row.menuLabel.setText(menus[i].title)
                    row.categoryLabel.setText(menus[i].category)
                    row.priceLabel.setText(numberFormatter.stringFromNumber(menus[i].price))
                }
            }
        }
    }
}

class MenusRowType: NSObject {
    @IBOutlet weak var menuLabel: WKInterfaceLabel!
    @IBOutlet weak var categoryLabel: WKInterfaceLabel!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
}
