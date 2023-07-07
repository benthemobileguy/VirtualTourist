//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//


import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    // Outlets
    
    @IBOutlet weak var activityIndicatorWidget: UIActivityIndicatorView! // Activity indicator to show while image is loading
    @IBOutlet weak var imageView: UIImageView! // Image view to display the photo
    
    // Initialize cell with a photo
    
    func initializeCellWithPhoto(_ photo: Photo) {
        if photo.imageData != nil {
            // If the photo already has image data, display it immediately
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: photo.imageData! as Data)
                self.activityIndicatorWidget.stopAnimating()
            }
        } else {
            // If the photo doesn't have image data, download the image
            downloadImageData(photo)
        }
    }
    
    // Download image for a photo
    
    func downloadImageData(_ photo: Photo) {
        URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
            if error == nil {
                // If image data is retrieved successfully, display the image
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data! as Data)
                    //set activity indicator widget from anaimating after the image is set
                    self.activityIndicatorWidget.stopAnimating()
                    //save image data to core data
                    self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
                }
            }
        }.resume()
    }
    
    // Save image data to Core Data
    
    func saveImageDataToCoreData(photo: Photo, imageData: NSData) {
        do {
            photo.imageData = imageData
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.coreDataStack
            try stack?.saveContext()
        } catch {
            print("Saving photo imageData failed")
        }
    }
}
