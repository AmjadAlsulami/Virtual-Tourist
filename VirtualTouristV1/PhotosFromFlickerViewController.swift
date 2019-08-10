//
//  ViewController.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 18/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import UIKit
import MapKit
import CoreData
//MARK: class PhotosFromFlickerViewController: UIViewController
class PhotosFromFlickerViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Properties
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var toDeletepinPhoto = IndexPath()
    var photoURLarray = [URL]()
    var photos:[Photo] = []
    var pin: Pin!
    
    // MARK: viewWillAppear(_ animated: Bool)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupfetchedController()
        
    }
    
    //MARK: override func viewDidDisappear(_ animated: Bool)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    //MARK:  override func viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isEnabled = false
        setFlowLayoutSize()
        zoomOnTheMap()
        setupfetchedController()
        checkIfThereisPhotos ()
        
    }
    
    //MARK: setFlowLayoutSize()
    func setFlowLayoutSize(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    //MARK : func zoomOnTheMap()
    func zoomOnTheMap(){
        //creat MKPointAnnotation object
        let annotation = MKPointAnnotation()
        //set Properties and the zoom
        let  mapcoordinate = CLLocationCoordinate2D(latitude:pin.latitude, longitude:  pin.longitude)
        annotation.coordinate = mapcoordinate
        self.theMap.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center:   annotation.coordinate, span: span)
        self.theMap.setRegion(region, animated: true)
        
    }
    
    //MARK: func checkIfThereisPhotos ()
    func checkIfThereisPhotos (){
        if self.fetchedResultsController.fetchedObjects?.count == 0{
            getFlickerPhotos()
        }
    }
    
    //MARK: func getFlickerPhotos()
    func getFlickerPhotos(){
        //start the fliker request
        FlickerParsingData.SharedPoint().gettingFlickersPhotosByLocation( latitude: pin.latitude, longitude: pin.longitude){(success, ResponseType,errorString)  in
            if success {
                if errorString == nil {
                    if let photo = ResponseType as? [PhotoInfo]{
                        for index in photo {
                            self.photoURLarray.append(URL(string: index.url_m)!)
                            self.photos.append(self.savePhototoCoreData())
                        }
                    }
                }
                else {
                    print("\(String(describing: errorString))")
                }
            }
        }
    }
    //MARK: func imageDownloadingbyURL()
    func imageDownloadingbyURL(imageURL:URL,completion: @escaping (_ data: Data) -> Void)  {
        //Start downloading images using -URLSession.shared.dataTask- method
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error == nil {
                completion(data!)
            }
        }
        task.resume()
    }
    
    //MARK: func savePhototoCoreData()-> Photo
    func savePhototoCoreData() -> Photo{
        //add photo to the store
        let photo = Photo(context: self.dataController.viewContext)
        photo.createdDate = Date()
        photo.pin = self.pin
        
        do
        {
            try self.dataController.viewContext.save()
        }
        catch
        {
            //ERROR
            print(error)
            
        }
        return photo
    }
    
    //MARK:  func removePhotofromoCoreData(isAcollection: Bool)
    func removePhotofromoCoreData(isAcollection: Bool) {
        //check if the deleting request was for all the Photo in the collection
        // if the new collection button clicked
        if  isAcollection {
            //get all  photo in the store
            guard let allDeletedPhoto = self.fetchedResultsController.fetchedObjects else {
                return
            }
            
            // start deliting them one by one
            for index in allDeletedPhoto {
                self.dataController.viewContext.delete(index)
                try? self.dataController.viewContext.save()
            }
        }
            //if the user only clicked 1 photo to delete
        else {
            //get the image from the store by using toDeletepinPhoto index
            let  deletedPhoto = self.fetchedResultsController.object(at: self.toDeletepinPhoto)
            //delete photo
            self.dataController.viewContext.delete(deletedPhoto)
            try? self.dataController.viewContext.save()
        }
    }
    
    //MARK: @IBAction func askForNewCollection(_ sender: Any)
    @IBAction func askForNewCollection(_ sender: Any) {
        newCollectionButton.isEnabled = false
        removePhotofromoCoreData(isAcollection: true)
        photoURLarray.removeAll()
        checkIfThereisPhotos ()
        
    }
    
    
    //MARK: func setupfetchedController()
    func setupfetchedController()  {
        // set fetchRequest
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        // set sort Descriptor  by "createdDate" and filtered by the pin
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Intalize NSFetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: self.pin)) -photos")
        // set the deleget to respones to the changes
        fetchedResultsController.delegate =  self
        // call performFetch() to start the work
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension PhotosFromFlickerViewController: UICollectionViewDataSource {
    //MARK:  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //  determine the number of rows in section
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    //MARK: func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "getFlickerCollectionViewCell", for: indexPath) as! getFlickerCollectionViewCell
        //start the loading place holder
        cell.startPlaceHolderIndicator()
        cell.flickerPhoto.image = UIImage(named: "placeholder-image")
        
        let arrayData = self.fetchedResultsController.fetchedObjects!
        //start fetching data
        if arrayData[(indexPath as NSIndexPath).row].image != nil {
            cell.flickerPhoto.image =  UIImage(data: arrayData[(indexPath as NSIndexPath).row].image!)
            //stop the loading place holder
            cell.stopPlaceHolderIndicator()
            //reEnable the new collection Button
            newCollectionButton.isEnabled = true
        }
        else {
            
            self.imageDownloadingbyURL(imageURL: self.photoURLarray[(indexPath as NSIndexPath).row]) { (data) in
                
                cell.flickerPhoto.image = UIImage(data: data)
                
                cell.stopPlaceHolderIndicator()
                self.newCollectionButton.isEnabled = true
                self.photos[indexPath.row].image = data
                try? self.dataController.viewContext.save()
                
            }
        }
        
        return cell
    }
    
}


extension PhotosFromFlickerViewController: UICollectionViewDelegate {
    //MARK:  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //set the deleted photo index
        self.toDeletepinPhoto = indexPath
        //call the removePhotofromoCoreData and set the isAcollection: false because its a single Photo to be removed
        removePhotofromoCoreData(isAcollection: false)
        
    }
}

//Mark : CoreData FetchedResultsController
extension PhotosFromFlickerViewController :NSFetchedResultsControllerDelegate {
    
    //MARK:  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,didChange anObject: Any,at indexPath: IndexPath?,for type: NSFetchedResultsChangeType,newIndexPath: IndexPath?)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        //track changes in the store and update the COLLECTION VIEW accordingley
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
            
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
            
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
            
        }
    }
}


