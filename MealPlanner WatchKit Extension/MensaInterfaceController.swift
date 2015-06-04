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
    private var mensa : Mensa?
    private var mealplan : Mealplan?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        mensa = context as? Mensa
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        
        if mensa != nil {
            self.setTitle(mensa!.name)
            Mealplan.CreateMealplan(mensa!, callback: {
                self.mealplan = $0
                // TODO figure out today
                let day = self.mealplan?.days[0]
                
                if let menus = day?.menus {
                    self.table.setNumberOfRows(menus.count, withRowType: "MenusRowType")
                    for var i = 0; i < menus.count; ++i {
                        let row = self.table.rowControllerAtIndex(i) as! MenusRowType
                        row.menuLabel.setText(menus[i].title)
                        row.categoryLabel.setText(menus[i].category)
                        row.priceLabel.setText(numberFormatter.stringFromNumber(menus[i].price))
                    }
                }
            })
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

class MenusRowType: NSObject {
    @IBOutlet weak var menuLabel: WKInterfaceLabel!
    @IBOutlet weak var categoryLabel: WKInterfaceLabel!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
}
