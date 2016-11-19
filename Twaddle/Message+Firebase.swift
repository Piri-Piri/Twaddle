//
//  Message+Firebase.swift
//  Twaddle
//
//  Created by David Pirih on 18.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData
import Firebase

extension Message: FirebaseModel {
    
    func upload(from context: NSManagedObjectContext, to rootRef: FIRDatabaseReference, usingAuth authObj: FIRAuth) {
        
        if chat?.storageId == nil {
            chat?.upload(from: context, to: rootRef, usingAuth: authObj)
        }
        
        let data = [
            "message" : text!,
            "sender"  : FirebaseStore.currentPhoneNumber!
        ]
        
        guard let chat = chat, let timestamp = timestamp, let storageId = chat.storageId else { return }
        
        // * note: no decimals in firebase allowed *
        let timeInterval = String(Int(timestamp.timeIntervalSince1970 * 100000))
        
        rootRef.child("chats/" + storageId + "/messages/" + timeInterval).setValue(data)
    }
}
