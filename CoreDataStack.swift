//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation
import CoreData

// Core Data Stack
struct CoreDataStack {
    
    private let modelURL: URL // The URL of the model file
    internal let databaseURL: URL // The URL of the SQLite database file
    let context: NSManagedObjectContext // The managed object context
    private let model: NSManagedObjectModel // The managed object model
    internal let coordinator: NSPersistentStoreCoordinator // The persistent store coordinator
   
    
    // Initialization method for creating a CoreDataStack instance
    init?(modelName: String) {
        
        // Find the URL of the model file in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            return nil
        }
        
        self.modelURL = modelURL
        
        // Create a managed object model from the model file URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Error creating a model from \(modelURL)")
            return nil
        }
        
        self.model = model
        
        // Create a persistent store coordinator with the managed object model
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a main queue concurrency type managed object context
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        let fm = FileManager.default
        
        // Get the URL of the Documents folder
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error got while trying to reach the Documents folder")
            return nil
        }
        
        self.databaseURL = docUrl.appendingPathComponent("VirtualTourist.sqlite")
        
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            // Add the persistent store to the coordinator
            try addPersistentStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject : AnyObject]?)
            
        } catch {
            print("Error derived while trying to add store at \(databaseURL)")
        }
    }
    
    // Method to add a persistent store to the coordinator
    func addPersistentStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject: AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
}

// Internal extension for additional functionality of CoreDataStack
internal extension CoreDataStack {
    
    // Method to drop all data from the persistent store
    func dropAllDataFromPersistentStore() throws {
        try coordinator.destroyPersistentStore(at: databaseURL, ofType: NSSQLiteStoreType, options: nil)
        try addPersistentStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: nil)
    }
}

// Extension for additional functionality of CoreDataStack
extension CoreDataStack {
    
    // Method to save the managed object context
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // Method to autosave the managed object context with a specified delay
    func autoSaveObject(_ delayInSeconds: Int) {
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            //call dispatch queue
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSaveObject(delayInSeconds)
            }
        }
    }
}
