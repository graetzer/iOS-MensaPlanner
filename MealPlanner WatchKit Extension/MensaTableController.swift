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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        table.setNumberOfRows(Globals.mensas.count, withRowType: "MensaRowType")
        
        for i in 0..<Globals.mensas.count {
            let row = table.rowControllerAtIndex(i) as! MensaRowType
            let mensa = Globals.mensas[i]
            
            let name = mensa.name.stringByReplacingOccurrencesOfString("Mensa ", withString: "")
            row.mensaTitle.setText(name)
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
//        if segueIdentifier == "PushMensa" {
            return Globals.mensas[rowIndex]
//        }
//        return nil
    }
    
    /// If opened from the glance
    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        self.pushControllerWithName("MensaInterfaceController", context: Globals.selectedMensa)
    }
}


class MensaRowType: NSObject {
    @IBOutlet weak var mensaTitle: WKInterfaceLabel!
}
