//
//  PhotoProperties.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//


import Foundation
import CoreData

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var index: Int16 // The index of the photo
    @NSManaged public var pin: Pin? // The associated pin
    @NSManaged public var imageData: NSData? // The data of the photo
    @NSManaged public var imageURL: String? // The URL of the photo
    
    
}

