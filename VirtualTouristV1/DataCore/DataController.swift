//
//  DataController.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 26/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation
import CoreData
// MARK: class DataController
class DataController {
    //Hold persistentContainer instanse
    let persistentContainer:NSPersistentContainer
    
     //Hold backgroundContext instanse
     var backgroundContext:NSManagedObjectContext!
    
   // acsess context
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
   
    // MARK:  init(modelName:String)
    init(modelName:String) {
      // make instanse of  persistent Container
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // MARK: configureContexts()
    func configureContexts() {
        //SET CONTEXT CONFIGRURATION FOR MIGRATION AND BACKGROUND ONES
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
       viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
     // MARK: func load(completion: (() -> Void)? = nil)
    func load(completion: (() -> Void)? = nil) {
          //load persistent store
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}


extension DataController {
    // MARK: autoSaveViewContext(interval:TimeInterval = 40)
    func autoSaveViewContext(interval:TimeInterval = 40) {
        debugPrint("the outsaving is done !")
        
        guard interval > 0 else {
        debugPrint("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
