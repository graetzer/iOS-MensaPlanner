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
    var day : Mealplan.Day? = nil {
        didSet {
            self.tableView.backgroundView = nil
            
            updateLoadingIndicator()
          if self.isViewLoaded {
                self.tableView.reloadData()
            }
        }
    }
    
    /// Currency formatter
  private let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "de_DE")
        
        self.tableView.allowsSelection = false;
      self.tableView.separatorStyle = .none
        updateLoadingIndicator()
    }

    // MARK: UITableViewDelegate
    
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menus = day?.menus {
            return menus.count
        }
        return 0
    }
    
    let MenuCell = "MenuCell"
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell, for: indexPath) as! MenuTableViewCell
    if let menu = day?.menus[indexPath.row] {
      cell.menuLabel.text = menu.title
      cell.categoryLabel.text = menu.category
      cell.priceLabel.text = numberFormatter.string(from:NSNumber(value:menu.price))
      
      if indexPath.row % 2 == 1 {
        if menu.price == 0 {
          cell.contentView.backgroundColor = UIColor(rgba: "#eaf0ff")
        } else {
          cell.contentView.backgroundColor = UIColor(rgba: "#F3F3F3")
        }
      } else {
        if menu.price == 0 {
          cell.contentView.backgroundColor = UIColor(rgba: "#f0f8ff")
        } else {
          cell.contentView.backgroundColor = nil
        }
      }
      cell.priceLabel.isHidden = menu.price == 0
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let date = day?.date {
      let label = UILabel(frame: CGRect.zero)
      label.backgroundColor = UIColor.white
      label.textAlignment = .center
      label.text = Mealplan.formatter.string(from: date)
      return label
    }
    return nil
  }
    
    
    func updateLoadingIndicator() {
        if self.day == nil {
          let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            self.tableView.backgroundView = indicator
            indicator.startAnimating()
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    func showNoDataFound() {
        let label = UILabel(frame: CGRect.zero)
//        if let note = self.day?.note {
//            label.text = note
//        } else {
            label.text = NSLocalizedString("No Data Found", comment: "empty mealplan message")
//        }
        label.textAlignment = .center
        self.tableView.backgroundView = label
    }
}

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
