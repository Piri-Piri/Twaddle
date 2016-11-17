//
//  ContextViewController.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

protocol ContextViewController {
    var context: NSManagedObjectContext? {get set}
}
