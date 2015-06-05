//
//  MensaSelectionController.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 05.06.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

class MensaSelectionController: UITableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Globals.mensas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MensaCell", forIndexPath: indexPath) as! MensaCell
        
        return cell
    }
    @IBAction func dismissSelection(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class MensaCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBAction func changedEnableValue(sender: AnyObject) {
    }
}