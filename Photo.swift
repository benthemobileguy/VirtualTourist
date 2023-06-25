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
    
    convenience init(index:Int, imageURL: String, imageData: NSData?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.index = Int16(index)
            self.imageURL = imageURL
            self.imageData = imageData
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
        }
    }
    
}
