//
//  ContextSyncer.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class ContextSyncer: NSObject {

    private var mainContext: NSManagedObjectContext
    private var backgroundContext: NSManagedObjectContext
    
    init(main: NSManagedObjectContext, background: NSManagedObjectContext) {
        self.mainContext = main
        self.backgroundContext = background
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mainContextSaved), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundContextSaved), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
        
    }
    
    func mainContextSaved(notification: Notification) {
        backgroundContext.perform {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    
    }
    
    func backgroundContextSaved(notification: Notification) {
        mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
