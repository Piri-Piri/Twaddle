//
//  CoreDataHelper.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

class CoreDataHelper {
    
    static let shared = CoreDataHelper()

    private init() {}

    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Twaddle")
        container.loadPersistentStores { (storeDescription, error) in
            
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    func saveContext() {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
