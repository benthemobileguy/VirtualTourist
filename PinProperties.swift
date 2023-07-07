//
//  PinProperties.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation
import CoreData

// Pin Class

extension Pin {
    
    // Fetch Pin
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    
    @NSManaged public var latitude: Double // The latitude of the pin
    @NSManaged public var longitude: Double // The longitude of the pin
    @NSManaged public var photo: NSSet? // The set of associated photos
    
}

// Access Photo

extension Pin {
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo) // Add a photo to the set of associated photos
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo) // Remove a photo from the set of associated photos
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet) // Add multiple photos to the set of associated photos
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet) // Remove multiple photos from the set of associated photos
    
}
