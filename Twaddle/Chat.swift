//
//  Chat.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

@objc(Chat)
public class Chat: NSManagedObject {

    var isGroupChat: Bool {
        
        guard let participantsCount = participants?.count else { return false }
        return participantsCount > 1
    }
    
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
    
    func add(participant contact: Contact) {
        mutableSetValue(forKey: "participants").add(contact)
    }
    
}
