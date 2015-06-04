//
//  MensasPagerController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 15.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

//GUITabPagerViewController, GUITabPagerDataSource, GUITabPagerDelegate
class MensasPagerController:SGTabbedPager, SGTabbedPagerDatasource {
    private var weekdayControl : UISegmentedControl? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = self
        
        weekdayControl = UISegmentedControl(items: ["Mo", "Di", "Mi", "Do", "Fr"])
        weekdayControl?.tintColor = UIColor.whiteColor()
        if let bar = self.navigationController?.navigationBar {
            weekdayControl?.frame = CGRectInset(bar.bounds, 0, 5)
        }
        weekdayControl?.addTarget(self, action: "changedDaySelection:", forControlEvents: .ValueChanged)
        self.navigationItem.titleView = weekdayControl
        
        let gregorian = NSCalendar.currentCalendar()
        gregorian.firstWeekday = 2 // Monday
        let weekday = gregorian.ordinalityOfUnit(.CalendarUnitWeekday, inUnit:.CalendarUnitWeekOfMonth, forDate: NSDate())
        if weekday < weekdayControl!.numberOfSegments+1 {
            self.weekdayControl?.selectedSegmentIndex = weekday - 1
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.reloadData()
    }
    
    // MARK: IBAction
    
    func changedDaySelection(sender: UISegmentedControl) {
        self.reloadData()
    }
    
    // MARK: SGTabbedPagerDatasource
    
    func numberOfViewControllers() -> Int {
        return Globals.mensas.count
    }
    
    func viewController(page:Int) -> UIViewController {
        //return demovc()
        let mensa = Globals.mensas[page]
        let mealTable = self.storyboard?.instantiateViewControllerWithIdentifier("MealsTableController") as! MealsTableController
        mealTable.mensa = mensa
        Mealplan.CreateMealplan(mensa, callback: { mealplan -> Void in
            var sel : Mealplan.Day? = nil
            for day in mealplan.days {
                if day.dayNumber == self.weekdayControl?.selectedSegmentIndex {
                    sel = day
                    break;
                }
            }
            mealTable.day = sel
        })
        return mealTable
    }
    
    func viewControllerTitle(page:Int) -> String {
        return "Mensa \(Globals.mensas[page].name)"
    }
}

