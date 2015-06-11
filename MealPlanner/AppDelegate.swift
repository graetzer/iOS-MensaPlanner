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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = Globals.rwthBlue
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackTranslucent
        return true
    }

    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

}

