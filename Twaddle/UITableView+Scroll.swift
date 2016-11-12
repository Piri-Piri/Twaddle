//
//  UITableView+Scroll.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

extension UITableView {

    func scrollToBottom() {
        if numberOfSections > 1 {
            let lastSection = numberOfSections - 1
            scrollToRow(at: IndexPath(row: numberOfRows(inSection: lastSection) - 1, section: lastSection),
                        at: .bottom,
                        animated: true)
        }
        else if numberOfRows(inSection: 0) > 0 && numberOfSections == 1 {
            scrollToRow(at: IndexPath(row: numberOfRows(inSection: 0) - 1, section: 0),
                             at: .bottom,
                             animated: true)
        }
    }
    
}
