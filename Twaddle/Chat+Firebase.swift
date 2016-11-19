//
//  Chat+Firebase.swift
//  Twaddle
//
//  Created by David Pirih on 18.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData
import Firebase

extension Chat: FirebaseModel {
    
    func observeMessages(from rootRef: FIRDatabaseReference, to context: NSManagedObjectContext) {
        
        guard let storageId = storageId else { return }
        let lastFetch = lastMessage?.timestamp?.timeIntervalSince1970 ?? 0
        
        rootRef
            .child("chats/" + storageId + "/messages")
            .queryOrderedByKey()
            .queryStarting(atValue: String(lastFetch * 100000))
            .observe(.childAdded, with: {
                snapshot in
                
                context.perform {
                    
                    guard let data = snapshot.value as? NSDictionary else { return }
                    guard let phoneNumber = data["sender"] as? String,
                        phoneNumber != FirebaseStore.currentPhoneNumber else { return }
                    guard let text = data["message"] as? String else { return }
                    guard let timeInterval = Double(snapshot.key) else { return }
                    
                    let date = NSDate(timeIntervalSince1970: timeInterval/100000)
                    
                    guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message else { return }
                    
                    message.text = text
                    message.timestamp = date
                    message.sender = Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, in: context) ?? Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, in: context)
                    message.chat = self
                    self.lastMessageTime = message.timestamp
                    
                    do {
                        try context.save()
                    } catch {
                        print("Error: Observing new messages failed: \(error.localizedDescription)")
                    }
                }
            })
    
    }
    
    static func new(forStoragId storageId: String, rootRef: FIRDatabaseReference, in context: NSManagedObjectContext) -> Chat {
        
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        
        chat.storageId  = storageId
        
        rootRef.child("chats/" + storageId + "/meta").observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let participantsDict = data["participants"] as? NSMutableDictionary else { return }
            
            participantsDict.removeObject(forKey: FirebaseStore.currentPhoneNumber!)
            let participants = participantsDict.allKeys.map {
                (phoneNumber : Any) -> Contact in
                
                let phoneNumberValue = phoneNumber as! String
                return Contact.existing(withPhoneNumber: phoneNumberValue, rootRef: rootRef, in: context) ?? Contact.new(forPhoneNumber: phoneNumberValue, rootRef: rootRef, in: context)
            }
            let name  = data["name"] as? String
            
            context.perform {
                
                chat.participants = NSSet(array: participants)
                chat.name = name
                do {
                    try context.save()
                } catch {
                    print("Error: Creating new chat with storage id failed: \(error.localizedDescription)")
                }
                chat.observeMessages(from: rootRef, to: context)
            }
        })
        
        return chat
    }
    
    static func existing(withStorageId storageId: String, in context: NSManagedObjectContext) -> Chat? {
        
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "storageId = %@", storageId)
        do {
            let chats = try context.fetch(request)
            if chats.count > 0 {
                if let chat = chats.first {
                    return chat
                }
            }
        } catch {
            print("Error: Fetching chat with storage id failed: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func upload(from context: NSManagedObjectContext, to rootRef: FIRDatabaseReference, usingAuth authObj: FIRAuth) {
        
        guard storageId == nil else { return }
        let ref = rootRef.child("chats").childByAutoId()
        storageId = ref.key
        
        var data: [String : Any] = [
            "id" : ref.key
        ]
        
        guard let participants = participants?.allObjects as? [Contact] else { return }
        var numbers = [FirebaseStore.currentPhoneNumber! : true]
        var userIds = [authObj.currentUser?.uid]
        
        for participant in participants {
            guard let phoneNumbers = participant.phoneNumbers?.allObjects as? [PhoneNumber] else { continue }
            guard let number = phoneNumbers.filter({ $0.registered }).first else { continue }
            
            numbers[number.value!] = true
            userIds.append(participant.storageId)
        }
        
        data["participant"] = numbers
        if let name = name {
            data["name"] = name
        }
        
        ref.setValue(["meta" : data])
        
        for id in userIds {
            guard let id = id else { continue }
            rootRef.child("users/" + id + "/chats/" + ref.key).setValue(true)
        }
    }
    
}
