//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Ben on 25/06/2023.
//  Copyright © 2023 Ben. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePins: UIView!
    
    // Variables
    
    var gestureBegin: Bool = false
    var editMode: Bool = false
    var currentPins: [Pin] = []
    
    // Core Data Stack
    
    lazy var coreDataStack: CoreDataStack = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.coreDataStack
    }()
    
    // Fetch Results
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let stack = coreDataStack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Load Saved Pin
    
    func preloadSavedPin() -> [Pin]? {
        do {
            var pinArray: [Pin] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<pinCount {
                pinArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            
            return pinArray
        } catch {
            return nil
        }
    }
    
    // View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRightBarButtonItem()
        
        let savedPins = preloadSavedPin()
        
        if let pins = savedPins {
            currentPins = pins
            
            // Add Annotation To Map
            
            for pin in currentPins {
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(fromCoord: coord)
            }
        }
    }
    
    // Bar Button Item
    
    func setRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // Gesture Recognizer
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureBegin = true
        return true
    }
    
    // Map View Function
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !editMode {
            performSegue(withIdentifier: "PinPhotos", sender: view.annotation?.coordinate)
            mapView.deselectAnnotation(view.annotation, animated: false)
        } else {
            removeCoreData(of: view.annotation!)
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    // Action
    
    @IBAction func responseLongTapAction(_ sender: Any) {
        if gestureBegin {
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            addAnnotationToMap(fromPoint: gestureTouchLocation)
            gestureBegin = false
        }
    }
    
    // Add Pin
    
    func addAnnotationToMap(fromPoint: CGPoint) {
        let coordToAdd = mapView.convert(fromPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordToAdd
        addCoreData(of: annotation)
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoord
        mapView.addAnnotation(annotation)
    }
    
    // Add Core Data
    
    func addCoreData(of: MKAnnotation) {
        do {
            let coord = of.coordinate
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: coreDataStack.context)
            try coreDataStack.saveContext()
            currentPins.append(pin)
        } catch {
            print("Add Core Data Failed")
        }
    }
    
    // Delete Core Data
    
    func removeCoreData(of: MKAnnotation) {
        let coord = of.coordinate
        for pin in currentPins {
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                do {
                    coreDataStack.context.delete(pin)
                    try coreDataStack.saveContext()
                } catch {
                    print("Remove Core Data Failed")
                }
                break
            }
        }
    }
    
    // Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinPhotos" {
            let destination = segue.destination as! PhotosViewController
            let coord = sender as! CLLocationCoordinate2D
            destination.selectedCoordinate = coord
            
            for pin in currentPins {
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    //set pin
                    destination.pin = pin
                    break
                }
            }
        }
    }
    
    // Edit
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deletePins.isHidden = !editing
        editMode = editing
    }
}
