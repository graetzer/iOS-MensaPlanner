//
//  ViewController.swift
//  MealPlanner
//
//  Created by Simon Grätzer on 15.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

class MealPlanController: GUITabPagerViewController, GUITabPagerDataSource, GUITabPagerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self;
        
        // TODO Auto select mensa from last time
        // do that with restoration
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
        // TODO load some data
    }

    // MARK: GUITabPagerDataSource
    func numberOfViewControllers() -> Int {
        return Globals.mensas.count
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController! {
        let mealTable = self.storyboard?.instantiateViewControllerWithIdentifier("MealsTableController") as! MealsTableController
        let mensa = Globals.mensas[index]
        mealTable.mensa = mensa
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mensa.url)
        var task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                println("\(error.localizedDescription)")
                return
            }
            let mensaplan = Mealplan(data: data)
            mealTable.day = mensaplan.today
        }
        task.resume()
        return mealTable
    }
    
    // MARK: GUITabPagerDelegate
    func titleForTabAtIndex(index: Int) -> String! {
        return Globals.mensas[index].name
        //return NSLocalizedString("empty", comment: "empty message")
    }
    
    func tabColor() -> UIColor! {
        return Globals.rwthBlue
    }

}

