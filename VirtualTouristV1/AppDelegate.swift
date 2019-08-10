//
//  AppDelegate.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 18/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // dataController instanse
    let dataController = DataController(modelName: "VirtualTouristV1")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // load persistense store
        dataController.load()
        
        // set the root viewcontroller and set the dataController properties to it
        let navigationController = window?.rootViewController as! UINavigationController
        let MapViewController = navigationController.topViewController as! MapViewController
        MapViewController.dataController = dataController
        
        return true
    }
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        saveViewContext()
    }
    
  
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    
    //MAEK: saveViewContext()
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
}


