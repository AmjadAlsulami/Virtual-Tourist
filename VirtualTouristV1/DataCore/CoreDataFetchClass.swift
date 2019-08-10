//
//  CoreDataFetchClass.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 01/02/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation
import CoreData
class CoreDataFetchClass {
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    
    init(typeName: NSFetchRequestResult){
        fetchedResultsController = NSFetchedResultsController<typeName>?
    }
 func setup() {
    
    let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pin")
    fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
    do {
        try fetchedResultsController.performFetch()
    } catch {
        fatalError("The fetch could not be performed: \(error.localizedDescription)")
    }
}
}
