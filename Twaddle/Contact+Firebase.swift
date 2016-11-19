//
//  Contact+Firebase.swift
//  Twaddle
//
//  Created by David Pirih on 18.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData
import Firebase

extension Contact: FirebaseModel {
    
    static func new(forPhoneNumber phoneNumberValue: String, rootRef: FIRDatabaseReference, in context: NSManagedObjectContext) -> Contact {
        
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
        let phoneNumber = NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: context) as! PhoneNumber
        
        phoneNumber.contact = contact
        phoneNumber.registered = true
        phoneNumber.value = phoneNumberValue
        
        contact.getContactId(to: context, withPhoneNumber: phoneNumberValue, from: rootRef)
        
        return contact
    }
    
    static func existing(withPhoneNumber phoneNumberValue: String, rootRef: FIRDatabaseReference, in context: NSManagedObjectContext) -> Contact? {
        
        let request: NSFetchRequest<PhoneNumber> = PhoneNumber.fetchRequest()
        request.predicate = NSPredicate(format: "value = %@", phoneNumberValue)
        do {
            let phonenumbers = try context.fetch(request)
            if phonenumbers.count > 0 {
                let contact = phonenumbers.first!.contact
                if contact?.storageId == nil {
                    contact?.getContactId(to: context, withPhoneNumber: phoneNumberValue, from: rootRef)
                }
                return contact
            }
        } catch {
            print("Error: Fetching contact with phone number failed: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getContactId(to context: NSManagedObjectContext, withPhoneNumber phoneNumber: String, from rootRef: FIRDatabaseReference) {
        
        rootRef.child("users")
            .queryOrdered(byChild: "phoneNumber")
            .queryEqual(toValue: phoneNumber)
            .observeSingleEvent(of: .value, with: {
                snapshot in
                
                guard let user = snapshot.value as? NSDictionary else { return }
                
                let uid = user.allKeys.first as? String
                context.perform {
                    
                    self.storageId = uid
                    do {
                        try context.save()
                    } catch {
                        print("Error: Fetching contact id with phone number failed: \(error.localizedDescription)")
                    }
                }
            })
    }
    
    func upload(from context: NSManagedObjectContext, to rootRef: FIRDatabaseReference, usingAuth authObj: FIRAuth) {
        
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else { return }
        for number in phoneNumbers {
            rootRef.child("users")
                .queryOrdered(byChild: "phoneNumber")
                .queryEqual(toValue: number.value)
                .observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    guard let user = snapshot.value as? NSDictionary else { return }
                    let uid = user.allKeys.first as? String
                    context.perform {
                        
                        self.storageId = uid
                        number.registered = true
                        do {
                            try context.save()
                        } catch {
                            print("Error: Saving uploaded user failed: \(error.localizedDescription)")
                        }
                        self.updateStatus(from: rootRef, to: context)
                    }
                })
        }
    }
    
    func updateStatus(from rootRef: FIRDatabaseReference, to context: NSManagedObjectContext) {
        
        rootRef.child("users/" + storageId! + "/status").observe(.value, with: {
            snapshot in
            
            guard let status = snapshot.value as? String else { return }
            context.perform {
                
                self.status = status
                do {
                    try context.save()
                } catch {
                    print("Error: Saving uploaded status failed: \(error.localizedDescription)")
                }
            }
        })
    }
    
}
