//
//  PinProperties.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation
import CoreData

    //Pin Class

extension Pin {
    
    //Fetch Pin
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: NSSet?
    
}
    //Access Photo

extension Pin {
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
    
}
