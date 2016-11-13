//
//  ChatCreationDelegate.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

protocol ChatCreationDelegate {
    func created(chat: Chat, inContext context: NSManagedObjectContext)
}
