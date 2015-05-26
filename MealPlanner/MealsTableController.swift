//
//  MealsTableController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import Foundation

/// Displays the meals for a day
class MealsTableController: UITableViewController {
    
    var mensa : Mensa?
    var day : Mealplan.Day? = nil {
        didSet {
            if self.isViewLoaded() {
                self.tableView.reloadData()
            }
        }
    }
    /// Currency formatter
    private let numberFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = mensa?.name
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        
        if day == nil {
            // TODO add loading indicator
            // Maybe not needed
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menus = day?.menus {
            return menus.count
        }
        return 0
    }
    
    let MensaCell = "MensaCell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MensaCell, forIndexPath: indexPath) as! MensaTableViewCell
        if let menu = day?.menus[indexPath.row] {
            cell.menuLabel.text = menu.title
            cell.categoryLabel.text = menu.category
            cell.priceLabel.text = numberFormatter.stringFromNumber(menu.price)
        }
        
        return cell
    }
    
}

class MensaTableViewCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}