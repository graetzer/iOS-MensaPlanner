//
//  AppDelegate.swift
//  MensaPlanner
//
//  Created by Simon Grätzer on 15.05.15.
//  Copyright (c) 2015 Simon Grätzer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
  
  public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    // Override point for customization after application launch.
    UINavigationBar.appearance().barTintColor = Globals.rwthBlue
    UINavigationBar.appearance().barStyle = UIBarStyle.blackTranslucent
    
    
    //let setting = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
    //application.registerUserNotificationSettings(setting)
    
    return true
  }

  func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

  func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let mensas = Globals.enabledMensas()
    var outstanding = mensas.count// will be 0 when done
    var newData = 0
    
    for mensa in mensas {
      Mealplan.LoadMealplan(mensa: mensa) { (mealplan, err) -> Void in
        outstanding -= 1
        if let plan = mealplan {
          if !plan.isCached {
            newData += 1
          }
          
          // all done
          if outstanding == 0 {
            
            /*
             let types = application.currentUserNotificationSettings()?.types
             if types != nil && types!.contains(.Alert) && !Globals.isWeekend() && !plan.isCached {
             let now = Globals.currentWeekday()
             for weekday in now...4 {
             if let day = mealplan?.dayForIndex(weekday) {// Select best day
             
             let local = UILocalNotification()
             
             // TODO
             
             }
             }
             }*/
            
            completionHandler(newData > 0 ? .newData : .noData)
          }
        }
      }
    }
  }
    
}

