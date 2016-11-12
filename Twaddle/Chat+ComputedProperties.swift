//
//  Chat+ComputedProperties.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

extension Chat {

    var lastMessage: Message? {
        
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        do {
            guard let msgs = try self.managedObjectContext?.fetch(request) else {
                return nil
            }
            return msgs.first
        } catch {
            print("Error: Fetching last message for chat failed: \(error.localizedDescription)")
        }
        return nil
    }
    
}
