//
//  MensasPagerController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 15.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

class MensasPagerController: GUITabPagerViewController, GUITabPagerDataSource, GUITabPagerDelegate {
    @IBOutlet
    var contentView : UIScrollView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        let control = UISegmentedControl(items: ["Mo", "Di", "Mi", "Do", "Fr"])
        control.tintColor = UIColor.whiteColor()
        if let bar = self.navigationController?.navigationBar {
            control.frame = CGRectInset(bar.bounds, 0, 5)
        }
        self.navigationItem.titleView = control
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.reloadData()
    }
    
    // MARK: GUITabPagerDataSource
    func numberOfViewControllers() -> Int {
        return Globals.mensas.count
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController! {
        let mensa = Globals.mensas[index]
        let mealTable = self.storyboard?.instantiateViewControllerWithIdentifier("MealsTableController") as! MealsTableController
        mealTable.mensa = mensa
        Mealplan.CreateMealplan(mensa, callback: {mealTable.day = $0.days[0]})
        return mealTable
    }
    
    // MARK: GUITabPagerDelegate
    func titleForTabAtIndex(index: Int) -> String! {
        return Globals.mensas[index].name
    }
    
    func tabColor() -> UIColor! {
        return Globals.rwthBlue
    }
}

