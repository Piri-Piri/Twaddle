//
//  Message.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

@objc(Message)
public class Message: NSManagedObject {

    var isIncoming: Bool {
        return sender != nil
    }

}
