//
//  FlickrImage.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import UIKit
import CoreData

class FlickrPhoto {
    
    let id: String // The ID of the Flickr image
    let secret: String // The secret of the Flickr image
    let server: String // The server of the Flickr image
    let farm: Int // The farm ID of the Flickr image
    
    init(id: String, secret: String, server: String, farm: Int) {
        // Initialize the FlickrImage instance with the provided values
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        // Generate and return the URL string for the Flickr image
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
}
