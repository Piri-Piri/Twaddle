//
//  FirebaseModel.swift
//  Twaddle
//
//  Created by David Pirih on 17.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData
import Firebase

protocol FirebaseModel {
    func upload(from context: NSManagedObjectContext, to rootRef: FIRDatabaseReference, usingAuth authObj: FIRAuth)
}
