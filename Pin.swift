//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation
import CoreData

// Pin Class
public class Pin: NSManagedObject {
    
    // Convenience initializer for creating a Pin object
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // Check if the entity name exists in the given context
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            // Initialize the Pin object with the given entity and insert it into the context
            self.init(entity: entity, insertInto: context)
            
            // Set the latitude and longitude properties of the Pin object
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            // If the entity name does not exist, raise a fatal error
            fatalError("Error trying to find entity name!")
        }
    }
}
