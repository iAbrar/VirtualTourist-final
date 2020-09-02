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
    
    
    var pin : Pin!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    var page = 1
    
    @IBOutlet var collection: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard  let lat = pin?.latitude else { return }
        guard  let lon = pin?.longitude else { return }
        
        collection.dataSource = self
        collection.delegate = self
        setupFetchedResultsController()
        
        if (fetchedResultsController.sections?[0].numberOfObjects == 0) {
            loadImages(lon, lat, page)
        }
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude:pin.latitude, longitude: pin.longitude)
        mapView.showAnnotations([annotation],animated: true)
        mapView.addAnnotation(annotation)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        guard  let lat = pin?.latitude else { return }
//        guard  let lon = pin?.longitude else { return }
//
//        page = 1
        setupFetchedResultsController()
        
//        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
//            loadImages(lon, lat, page)
//        }
//        collection.reloadData()
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
            
            
            cell.imageView.kf.setImage(with: imageUrl, placeholder: image, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                if ((error) != nil) {
                    print("error in setting data")
                } else {
                    photo.data = image?.pngData()
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
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("error")
                }
            }
        }
        page = page+1
        
        loadImages(pin!.longitude, pin!.latitude, page)
       
    }
    
    @IBAction func deleteImagesTapped(_ sender: UIButton) {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("error")
                }
            }
        }
        collection.reloadData()
    }
    
    fileprivate func addPhoto(_ url: String) {
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.url = url
        photo.pin = pin
        print("pin :", pin.longitude)
        try? dataController.viewContext.save()
    }
    
    fileprivate func loadImages(_ lon: Double, _ lat: Double, _ page: Int) {
        FlickrAPI.downloadJSON(longitude: lon, latitude: lat, page: page)
        { images, error in
            
            
            guard error == nil else {
                self.showAlert(title: "Error", message: error!)
                return
            }
            for image in images
            {
                self.addPhoto(image)
            }
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        print("fetch pin info", pin.longitude)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.creationDate!)-photos")
        
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
