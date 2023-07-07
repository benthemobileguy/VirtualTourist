//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation
import CoreData

    //Photo Class

public class Photo: NSManagedObject {
    
    convenience init(index: Int, imageURL: String, imageData: NSData?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: ent, insertInto: context)
            
            self.imageURL = imageURL // The URL of the photo
            self.imageData = imageData // The data of the photo
            self.index = Int16(index) // The index of the photo
            
        } else {
            
            fatalError("Error Trying To Find Entity Name!")
        }
    }
    
}

