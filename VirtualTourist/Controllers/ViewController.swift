//
//  ViewController.swift
//  VirtualTourist
//
//  Created by imac on 8/18/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupFetchResultsController()
        if let pins = fetchedResultsController.fetchedObjects{
            
            //TODO update the map for each pin in pins add them to the map
            for pin in pins {
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func addPinTapped(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locationCoordinator = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: locationCoordinator.latitude, longitude: locationCoordinator.longitude)
        
        addPin(latitude: locationCoordinator.latitude, longitude: locationCoordinator.longitude)
        
        mapView.addAnnotation(annotation)
        
    }
    
    /// Adds a new pin to the end of the `pins` array
    func addPin(latitude: Double, longitude: Double ) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
        
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pin) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pin)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation! , animated: true)
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = (view.annotation?.coordinate.latitude)!
        pin.longitude = (view.annotation?.coordinate.longitude)!
        pin.creationDate = Date()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController;
        
        vc.pin = pin
        vc.dataController = dataController
        
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else{
            return print("error in inseting a pin ")
        }
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        
        switch type {
        case .insert:
            mapView.addAnnotation(annotation)
            break
        default: ()
        }
    }
}

