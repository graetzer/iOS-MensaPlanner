//
//  MensasPagerController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 15.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit



//GUITabPagerViewController, GUITabPagerDataSource, GUITabPagerDelegate
class MensasPagerController:SGTabbedPager, SGTabbedPagerDatasource, SGTabbedPagerDelegate {
    private var weekdayControl : UISegmentedControl! = nil
    private var mensas : [Mensa] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = self
        
        weekdayControl = UISegmentedControl(items: ["Mo", "Di", "Mi", "Do", "Fr"])
        weekdayControl.tintColor = UIColor.whiteColor()
        if let bar = self.navigationController?.navigationBar {
            weekdayControl.frame = CGRectInset(bar.bounds, 0, 5)
        }
        weekdayControl.addTarget(self, action: "changedDaySelection:", forControlEvents: .ValueChanged)
        self.navigationItem.titleView = weekdayControl
        
        // Let's try to make today the current day
        let weekday = Globals.currentWeekdayIndex()
        self.weekdayControl.selectedSegmentIndex = min(weekdayControl!.numberOfSegments-1, max(weekday, 0))
    }
    
    override func viewWillAppear(animated: Bool) {
        mensas = Globals.enabledMensas()
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let bar = self.navigationController?.navigationBar {
            weekdayControl.frame = CGRectInset(bar.bounds, 0, 5)
        }
    }
    
    // MARK: IBAction
    
    func changedDaySelection(sender: UISegmentedControl) {
        self.reloadData()
    }
    
    // MARK: SGTabbedPagerDatasource
    
    func numberOfViewControllers() -> Int {
        return mensas.count
    }
    
    func viewController(page:Int) -> UIViewController {
        //return demovc()
        let mensa = mensas[page]
        let mealTable = self.storyboard?.instantiateViewControllerWithIdentifier("MealsTableController") as! MealsTableController
        Mealplan.CreateMealplan(mensa, callback: { (mealplan, err) -> Void in
            let weekday = self.weekdayControl.selectedSegmentIndex
            if let day = mealplan?.dayForIndex(weekday) {// Select best day
                mealTable.day = day
            } else {
                mealTable.showNoDataFound()
            }
        })
        return mealTable
    }
    
    func viewControllerTitle(page:Int) -> String {
        return mensas[page].name
    }
    
    // MARK: SGTabbedPagerDelegate
    
    func didShowViewController(page: Int) {
        // Used for glances on watchOS
        Globals.selectedMensa = mensas[page]
    }
}

