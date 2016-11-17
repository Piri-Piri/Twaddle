//
//  TableViewFetchedResultDisplayer.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

protocol TableViewFetchedResultsDisplayer {
    func configure(cell: UITableViewCell, at indexPath: IndexPath)
}
