//
//  DataController.swift
//  VirtualTourist
//
//  Created by imac on 8/31/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    let presistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return presistentContainer.viewContext
    }
    
    init(modelName:String) {
        presistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion:(() -> Void)? = nil){
        presistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
            
        }
    }
    
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
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
