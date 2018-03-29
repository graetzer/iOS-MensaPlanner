//
//  MensaTableController.swift
//  MealPlanner WatchKit Extension
//
//  Created by Simon Grätzer on 28.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import WatchKit
import Foundation


class MensaTableController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
  
  // context from controller that did push or modal presentation. default does nothing
  override func awake(withContext context: Any?) {
    super.awake(withContext:context)
    table.setNumberOfRows(Globals.mensas.count, withRowType: "MensaRowType")
    
    for i in 0..<Globals.mensas.count {
      let row = table.rowController(at: i) as! MensaRowType
      let mensa = Globals.mensas[i]
      
      let name = mensa.name.replacingOccurrences(of: "Mensa ", with: "")
      row.mensaTitle.setText(name)
    }
  }
  
  override func contextForSegue(withIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    //        if segueIdentifier == "PushMensa" {
    return Globals.mensas[rowIndex]
    //        }
    //        return nil
  }
  
  /// If opened from the glance
  override func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
    self.pushController(withName: "MensaInterfaceController", context: Globals.selectedMensa)
  }
}


class MensaRowType: NSObject {
    @IBOutlet weak var mensaTitle: WKInterfaceLabel!
}
