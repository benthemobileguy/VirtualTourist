//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Ben Chukwuma on 25/06/2023.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // Outlets
      
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet var noPhotosLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Variables
    
    var selectedCoordinate: CLLocationCoordinate2D!
    let spacingBetweenItems: CGFloat = 5
    let totalCellCount: Int = 25
    
    var coreDataStack: CoreDataStack!
    var pin: Pin!
    var savedPhotos: [Photo] = []
    var selectedToDelete: [Int] = [] {
        didSet {
            if selectedToDelete.count > 0 {
                newCollectionBtn.setTitle("Remove Selected Pictures", for: .normal)
            } else {
                newCollectionBtn.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    // Core Data Stack
    
    func getCoreDataStack() -> CoreDataStack {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.coreDataStack
    }
    
    // Fetch Results
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let stack = getCoreDataStack()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Preload Saved Photos
    
    func preloadSavedPhotos() -> [Photo]? {
        do {
            var photoArray: [Photo] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<photoCount {
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            return photoArray.sorted(by: { $0.index < $1.index })
        } catch {
            return nil
        }
    }
    
    // View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Flow Layout
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Button & Label
        newCollectionBtn.isHidden = false
        noPhotosLabel.isHidden = true
        
        // Add To Map
        collectionView.allowsMultipleSelection = true
        addAnnotationToMap()
        
        // Fetch Photos
        let savedPhotos = preloadSavedPhotos()
        if savedPhotos != nil && savedPhotos?.count != 0 {
            self.savedPhotos = savedPhotos!
            showSavedResults()
        } else {
            showNewResults()
        }
    }
    
    // New Collection Action
    
    @IBAction func newCollectionAction(_ sender: Any) {
        if selectedToDelete.count > 0 {
            removeSelectedPhotosFromCoreData()
            unselectAllSelectedCollectionViewCells()
            savedPhotos = preloadSavedPhotos()!
            showSavedResults()
        } else {
            showNewResults()
        }
    }
    
    // Deselect Collection View Cells
    
    func unselectAllSelectedCollectionViewCells() {
        for indexPath in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    // Remove Photos from Core Data
    
    func removeSelectedPhotosFromCoreData() {
        for index in 0..<savedPhotos.count {
            if selectedToDelete.contains(index) {
                getCoreDataStack().context.delete(savedPhotos[index])
            }
        }
        
        do {
            try getCoreDataStack().saveContext()
        } catch {
            print("Failed to remove photos from Core Data")
        }
        
        selectedToDelete.removeAll()
    }
    
    // Show Saved Results
    
    func showSavedResults() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // Show New Results
    
    func showNewResults() {
        newCollectionBtn.isEnabled = false
        deleteExistingCoreDataPhotos()
        savedPhotos.removeAll()
        collectionView.reloadData()
        
        getFlickrRandomPhotos { (flickrPhotos) in
            if flickrPhotos != nil {
                DispatchQueue.main.async {
                    self.addPhotosToCoreData(flickrPhotos: flickrPhotos!, pin: self.pin)
                    self.savedPhotos = self.preloadSavedPhotos()!
                    self.showSavedResults()
                    self.newCollectionBtn.isEnabled = true
                }
            }
        }
    }
    
    // Add Photos to Core Data
    
    func addPhotosToCoreData(flickrPhotos: [FlickrPhoto], pin: Pin) {
        for photo in flickrPhotos {
            do {
                let coreDataStack = getCoreDataStack()
                let photoObject = Photo(index: flickrPhotos.index { $0 === photo }!, imageURL: photo.imageURLString(), imageData: nil, context: coreDataStack.context)
                photoObject.pin = pin
                try coreDataStack.saveContext()
            } catch {
                print("Failed to add photo to Core Data")
            }
        }
    }
    
    // Delete Existing Core Data Photos
    
    func deleteExistingCoreDataPhotos() {
        for photo in savedPhotos {
            getCoreDataStack().context.delete(photo)
        }
    }
    
    // Get Random Flickr Photos
    
    func getFlickrRandomPhotos(completion: @escaping (_ photos: [FlickrPhoto]?) -> Void) {
        var photos: [FlickrPhoto] = []
        
        FlickrNetwork.getFlickrPhotosRandomly(lat: selectedCoordinate.latitude, lng: selectedCoordinate.longitude) { (success, flickrPhotos) in
            if success {
                if flickrPhotos!.count > self.totalCellCount {
                    var randomArray: [Int] = []
                    
                    while randomArray.count < self.totalCellCount {
                        let random = arc4random_uniform(UInt32(flickrPhotos!.count))
                        if !randomArray.contains(Int(random)) {
                            randomArray.append(Int(random))
                        }
                    }
                    
                    for random in randomArray {
                        photos.append(flickrPhotos![random])
                    }
                    
                    completion(photos)
                } else {
                    completion(flickrPhotos!)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    // Add Annotation to Map
    
    func addAnnotationToMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated:true)
    }
    
    // Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        cell.activityIndicatorWidget.startAnimating()
        cell.initializeCellWithPhoto(savedPhotos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedToDelete = selectedIndexesFromIndexPaths(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedToDelete = selectedIndexesFromIndexPaths(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1
        }
    }
    
    // Get Selected Indexes from Index Paths
    
    func selectedIndexesFromIndexPaths(_ indexPaths: [IndexPath]) -> [Int] {
        var selectedIndexes: [Int] = []
        
        for indexPath in indexPaths {
            selectedIndexes.append(indexPath.row)
        }
        
        return selectedIndexes
    }
}
