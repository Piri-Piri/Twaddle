
//
//  FirebaseStore.swift
//  Twaddle
//
//  Created by David Pirih on 17.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class FirebaseStore {

    fileprivate let context: NSManagedObjectContext

    fileprivate let rootRef = FIRDatabase.database().reference()
    fileprivate let authObj = FIRAuth.auth()
    
    fileprivate(set) static var currentPhoneNumber: String? {
        set(phoneNumber) {
            UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        }
        get {
            return UserDefaults.standard.object(forKey: "phoneNumber") as? String
        }
    }
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func hasAuth() -> Bool {
        
        return authObj?.currentUser != nil
    }
    
    fileprivate func upload(model: NSManagedObject) {
        
        guard let model = model as? FirebaseModel else { return }
        guard let authObj = authObj else { return }
        model.upload(from: context, to: rootRef, usingAuth: authObj)
    }
    
    private func listenForNewMessages(at chat: Chat) {
        
        chat.observeMessages(from: rootRef, to: context)
    }
    
    private func fetchAppContacts() -> [Contact] {
        
        do {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.predicate = NSPredicate(format: "storageId != nil")
            
            let contacts = try self.context.fetch(request)
            return contacts
        } catch {
            print("Error: Fetching app contact failed: \(error.localizedDescription)")
        }
        
        return []
    }
    
    private func observeUserStatus(contact: Contact) {
        
        contact.updateStatus(from: rootRef, to: context)
    }
    
    fileprivate func observeUserStates() {
        
        let contacts = fetchAppContacts()
        contacts.forEach(observeUserStatus)
    }
    
    fileprivate func observeChats() {
        
        guard let uid = self.authObj?.currentUser?.uid else { return }
        self.rootRef
            .child("users/" + uid + "/chats")
            .observe(.childAdded, with: {
                snapshot in
                
                let uid = snapshot.key
                let chat = Chat.existing(withStorageId: uid, in: self.context) ?? Chat.new(forStoragId: uid, rootRef: self.rootRef, in: self.context)
                
                if chat.isInserted {
                    do {
                        try self.context.save()
                    } catch {
                        print("Error: Observing existin/new chat failed: \(error.localizedDescription)")
                    }
                }
                self.listenForNewMessages(at: chat)
            })
    }

}

extension FirebaseStore: RemoteStore {

    func startSyncing() {
        context.perform {
            self.observeUserStates()
            self.observeChats()
        }
    }
    
    func store(inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        
        inserted.forEach(upload)
        do {
            try context.save()
        } catch {
            print("Error: Saving to remote store failed: \(error)")
        }
        
    }
    
    func signUp(phoneNumber: String, email: String, password: String, success: @escaping () -> (), error errorHandler: @escaping (String) -> ()) {
        
        authObj?.createUser(withEmail: email, password: password, completion: {
            (user, error) in
            
            if error != nil {
                errorHandler(error!.localizedDescription)
            } else {
                let newUser = [
                    "phoneNumber" : phoneNumber
                ]
                FirebaseStore.currentPhoneNumber = phoneNumber
                let uid = user?.uid
                self.rootRef.child("users").child(uid!).setValue(newUser)
                self.authObj?.signIn(withEmail: email, password: password, completion: {
                    (user, error) in
                    
                    if error != nil {
                        errorHandler(error!.localizedDescription)
                    } else {
                        success()
                    }
                })
            }
        })
    }

}
