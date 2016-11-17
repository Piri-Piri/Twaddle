//
//  FavoriteCell.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {

    let phoneTypeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        detailTextLabel?.textColor = UIColor.lightGray
        phoneTypeLabel.textColor = UIColor.lightGray
        phoneTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(phoneTypeLabel)
        
        phoneTypeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        phoneTypeLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
