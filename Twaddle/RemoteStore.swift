//
//  RemoteStore.swift
//  Twaddle
//
//  Created by David Pirih on 17.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

protocol RemoteStore {
    func signUp(phoneNumber: String, email: String, password: String, success: @escaping () -> (), error errorCallback: @escaping (String) -> ())
    func startSyncing()
    func store(inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject])
}
