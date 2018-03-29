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
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale(identifier: "de_DE")
    let mensa = context as! Mensa
    
    let name = mensa.name.replacingOccurrences(of: "Mensa ", with: "")
    self.setTitle(name)
    Mealplan.LoadMealplan(mensa: mensa) {(mealplan, error) in
      if mealplan == nil {
        let nodata = NSLocalizedString("No Data Found", comment: "empty mealplan message")
        self.setTitle(nodata)
      }
      
      // Select best day
      let weekday = Globals.currentWorkdayIndex()
      if let menus = mealplan?.dayForIndex(weekday: weekday)?.menus {
        self.table.setNumberOfRows(menus.count, withRowType: "MenusRowType")
        for i in 0..<menus.count {
          let row = self.table.rowController(at: i) as! MenusRowType
          row.menuLabel.setText(menus[i].title)
          row.categoryLabel.setText(menus[i].category)
          row.priceLabel.setText(numberFormatter.string(from: NSNumber(value: menus[i].price)))
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
