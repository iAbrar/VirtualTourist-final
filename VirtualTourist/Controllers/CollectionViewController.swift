//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by imac on 8/23/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit
import CoreData


private let reuseIdentifier = "customCell"

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
//    var photos: [Photo] = []
    var pin : Pin!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    var page = 1
    
    @IBOutlet var collection: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        setupFetchedResultsController()

        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude:pin.latitude, longitude: pin.longitude)
        
        mapView.addAnnotation(annotation)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard  let lat = pin?.latitude else { return }
        guard  let lon = pin?.longitude else { return }
        
        page = 1
        setupFetchedResultsController()

        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
        loadImages(lon, lat, page)
        }
        collection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        let image = UIImage(named: "placeholder")
        
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else if let url = photo.url {
            guard let imageUrl = URL(string: url) else{
                return cell
            }
        
        
        cell.imageView.kf.setImage(with: imageUrl, placeholder: image, options: nil, progressBlock: nil) { (imge, error, cacheType, url) in
                if ((error) != nil) {
                    
                } else {
                    photo.data = imge?.pngData()
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("error")
        }
        print("delete")
        
    }
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        
        page = page+1
        
        loadImages(pin!.longitude, pin!.latitude, page)
         collection.reloadData()
    }
    
    fileprivate func loadImages(_ lon: Double, _ lat: Double, _ page: Int) {
        FlickrAPI.downloadJSON(longitude: lon, latitude: lat, page: page)
        { images, error in
            
            
            if error == nil
            {
                DispatchQueue.main.async {
                    
                    for image in images
                    {
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.creationDate = Date()
                        photo.url = image
                        photo.pin = self.pin
                        try? self.dataController.viewContext.save()
                    }
                    self.collection.reloadData()
                    
                }
              
            }
            
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
    // center the mapView on the selected pin
    let region = MKCoordinateRegion(center: view.annotation!.coordinate, span: mapView.region.span)
    mapView.setRegion(region, animated: true)
    }
    
}

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collection.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collection.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
}
