//
//  FlickrNetwork.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import Foundation

// Network class for interacting with the Flickr API
class FlickrNetwork {
    
    // API Keys and Endpoint
    private static let flickrSearch = "flickr.photos.search"
    private static let format = "json"
    private static let searchRangeKM = 10
    private static let flickrEndpointURL = "https://api.flickr.com/services/rest/"
    private static let flickrAPIKey = "27331f6b3f5a4905a2c0190d6329641d"
    
    // Method to fetch Flickr images based on latitude and longitude
    static func getFlickrPhotosRandomly(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages: [FlickrPhoto]?) -> Void) {
        // Construct the request URL with the necessary parameters
        let request = NSMutableURLRequest(url: URL(string: "\(flickrEndpointURL)?method=\(flickrSearch)&format=\(format)&api_key=\(flickrAPIKey)&lat=\(lat)&lon=\(lng)&radius=\(searchRangeKM)")!)
        
        let session = URLSession.shared
        
        let sessionTask = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                // Error occurred while making the request
                completion(false, nil)
                return
            }
            
            // Trim the response data to remove the JSONP callback
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String: Any],
               let photosMeta = json["photos"] as? [String: Any],
               let photos = photosMeta["photo"] as? [Any] {
                // Extract the required information from the JSON response
                var flickrImages: [FlickrPhoto] = []
                
                for photo in photos {
                    if let flickrImage = photo as? [String: Any],
                       let id = flickrImage["id"] as? String,
                       let server = flickrImage["server"] as? String,
                       let secret = flickrImage["secret"] as? String,
                       let farm = flickrImage["farm"] as? Int {
                        flickrImages.append(FlickrPhoto(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                // Call the completion handler with the retrieved images
                completion(true, flickrImages)
                
            } else {
                // Error occurred while parsing the response
                completion(false, nil)
            }
        }
        //resume task here
        sessionTask.resume()
    }
}
