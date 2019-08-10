//
//  MapViewController.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 25/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import UIKit
import MapKit
import CoreData
//MARK: class MapViewController: UIViewController
class MapViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var theMap: MKMapView!
    
    // MARK: Properties
    var annotations = [MKPointAnnotation] ()
    var pin : Pin!
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    
    // MARK:override func viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGesture()
        setupfetchedController()
        setPinOnTheMap()
        
    }
    
    //Mark : viewWillAppear(_ animated: Bool)
    override func viewWillAppear(_ animated: Bool) {
        //call the setupfetchedController
        setupfetchedController()
        
    }
    
    //Mark :  override func viewDidDisappear(_ animated: Bool)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //Mark : func longPressGesture()
    func longPressGesture(){
        let lGesture = UILongPressGestureRecognizer(target: self, action:
            #selector(createPin(_:)))
        theMap.addGestureRecognizer(lGesture)
    }
    
    @objc func createPin(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            
            let location = sender.location(in:self.theMap)
            
            let Locationcoordinats = self.theMap.convert(location , toCoordinateFrom: self.theMap)
            //add pin to the core data
            addPin(latitude: Locationcoordinats.latitude, longitude: Locationcoordinats.longitude)
            
        }
    }
    
    
    ////Mark : func addPin(latitude:Double , longitude: Double)
    func addPin(latitude:Double , longitude: Double) {
        // add pin to the store
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.createdDate = Date()
        try? dataController.viewContext.save()
        
        
    }
    
    //Mark : func setPinOnTheMap()
    func setPinOnTheMap(){
        for place in fetchedResultsController.fetchedObjects! {
            
            let latitude = place.latitude
            let longitude = place.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.annotations.append(annotation)
            
        }
        DispatchQueue.main.async {
            self.theMap.addAnnotations(self.annotations)
            
        }
        
    }
    
    //Mark : override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "PhotosFromFlicker" ) {
            if let vc = segue.destination as? PhotosFromFlickerViewController {
                vc.pin = self.pin
                vc.dataController = self.dataController
                
            }
        }
        
    }
    
    //Mark : private func setupfetchedController()
    private func setupfetchedController() {
        // set fetchRequest
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        // set sort Descriptor  by "createdDate"
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Intalize NSFetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pins")
        // set the deleget to respones to the changes
        fetchedResultsController.delegate = self
        // call performFetch() to start the work
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    //Mark :  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation
        //get coordnates
        let latitudeINannotation  = annotation?.coordinate.latitude
        let longitudeINannotation = annotation?.coordinate.longitude
        mapView.deselectAnnotation(view.annotation, animated: true)
        //get pin from the store
        if let result = fetchedResultsController.fetchedObjects {
            //search for the clicked pin
            for pin in result {
                if pin.latitude == latitudeINannotation && pin.longitude == longitudeINannotation {
                    //set it to the local pin properties
                    self.pin = pin
                    performSegue(withIdentifier: "PhotosFromFlicker", sender: self)
                    break
                }
            }
        }
        
    }
    
    //MARK: func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //set pin in the  map
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}


extension MapViewController :NSFetchedResultsControllerDelegate {
    
    //MARK:  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            fatalError("All changes observed in the map view controller should be for Point instances")
        }
        //track changes in the store and update the map accordingley
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.theMap.addAnnotation(pin)
            }
            break
        case .delete:
            theMap.removeAnnotation(pin)
            break
        case .update:
            theMap.removeAnnotation(pin)
            theMap.addAnnotation(pin)
        default: break
            
        }
    }
    
}
