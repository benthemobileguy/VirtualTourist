//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? // The main window of the application
    var coreDataStack: CoreDataStack! // The CoreDataStack instance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create an instance of CoreDataStack with the given model name
        coreDataStack = CoreDataStack(modelName: "CoreDataModel")
        return true
    }
    
}


