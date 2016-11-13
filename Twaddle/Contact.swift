//
//  Contact.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

@objc(Contact)
public class Contact: NSManagedObject {

    var sortLetter: String {
        
        let letter = lastName?.characters.first ?? firstName?.characters.first
        return String(letter!)
    }
    
    var fullName: String {
        
        var fullName = ""
        if let firstName = firstName {
            fullName += firstName
        }
        if let lastName = lastName {
            if fullName.characters.count > 0 {
                fullName += " "
            }
            fullName += lastName
        }
        return fullName
    }
    
}
