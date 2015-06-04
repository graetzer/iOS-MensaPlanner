//
//  MealsTableController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 16.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

/// Displays the meals for a day
class MealsTableController: UITableViewController {
    
    var mensa : Mensa? = nil {
        didSet {
            self.title = mensa?.name
        }
    }
    var day : Mealplan.Day? = nil {
        didSet {
            self.tableView.backgroundView = nil
            
            updateEmptyIndicator()
            if self.isViewLoaded() {
                self.tableView.reloadData()
            }
        }
    }
    
    /// Currency formatter
    private let numberFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        
        self.tableView.allowsSelection = false;
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateEmptyIndicator()
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
            
            if indexPath.row % 2 == 1 {
                cell.contentView.backgroundColor = UIColor(rgba: "#F3F3F3")
            } else {
                cell.contentView.backgroundColor = nil
            }
        }
        
        return cell
    }
    
    func updateEmptyIndicator() {
        if self.day == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            self.tableView.backgroundView = indicator
            self.tableView.separatorStyle = .None
            indicator.startAnimating()
        } else if self.day?.menus.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
        } else {
            let label = UILabel(frame: CGRectZero)
            if let note = self.day?.note {
                label.text = note
            } else {
                label.text = NSLocalizedString("No Data Found", comment: "empty mealplan message")
            }
            label.textAlignment = .Center
            self.tableView.backgroundView = label
            self.tableView.separatorStyle = .None
        }
    }
}

class MensaTableViewCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}