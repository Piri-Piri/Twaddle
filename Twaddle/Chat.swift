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
    
    static func existing(directWith contact: Contact, in context: NSManagedObjectContext) -> Chat? {
    
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "ANY participants = %@ AND participants.@count = 1", contact)
        do {
            let chats = try context.fetch(request)
            return chats.first
        } catch {
            print("Error: Fetching existing chat failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    static func new(directWith contact: Contact, in context: NSManagedObjectContext) -> Chat {
        
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        chat.add(participant: contact)
        return chat
    }
    
}
