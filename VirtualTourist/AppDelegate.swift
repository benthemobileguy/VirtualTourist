//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import UIKit
import CoreData

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "CoreDataModel")!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
}
