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
    
    var remoteStore: RemoteStore?
    
    init(main: NSManagedObjectContext, background: NSManagedObjectContext) {
        self.mainContext = main
        self.backgroundContext = background
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(mainContextSaved), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundContextSaved), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
        
    }
    
    func mainContextSaved(notification: Notification) {
        backgroundContext.perform {
            
            guard let userInfo = notification.userInfo else { return }
            let userInfoDict = userInfo as NSDictionary
            
            let insertedObjs = self.objects(forKey: NSInsertedObjectsKey,
                                            dictionary: userInfoDict,
                                            context: self.backgroundContext)
            let updatedObjs = self.objects(forKey: NSUpdatedObjectsKey,
                                           dictionary: userInfoDict,
                                           context: self.backgroundContext)
            let deletedObjs = self.objects(forKey: NSDeletedObjectsKey,
                                           dictionary: userInfoDict,
                                           context: self.backgroundContext)
            
            self.remoteStore?.store(inserted: insertedObjs, updated: updatedObjs, deleted: deletedObjs)
            
            // TODO: may not needed under iOS10
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func backgroundContextSaved(notification: Notification) {
        mainContext.perform {
            
            // TODO: may not needed under iOS10
            self.objects(forKey: NSUpdatedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.mainContext).forEach { $0.willAccessValue(forKey: nil) }
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func objects(forKey key: String, dictionary: NSDictionary, context: NSManagedObjectContext) -> [NSManagedObject] {
        
        guard let set = (dictionary[key] as? NSSet) else { return [] }
        guard let objects  = set.allObjects as? [NSManagedObject] else { return [] }
        
        return objects.map { context.object(with: $0.objectID) }
    }
}
