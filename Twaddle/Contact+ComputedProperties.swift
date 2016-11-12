//
//  Contact+ComputedProperties.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData

extension Contact {

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
