//
//  UIViewController+FillWithView.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func fillViewWith(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let subviewConstraints: [NSLayoutConstraint] = [
            subview.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(subviewConstraints)
    }
    
}
