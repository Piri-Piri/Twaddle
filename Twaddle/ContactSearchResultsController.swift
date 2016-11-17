//
//  ContactSearchResultsController.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class ContactSearchResultsController: UITableViewController {

    fileprivate var filteredContacts = [Contact]()
    
    var contactSelector: ContactSelector?
    
    var contacts = [Contact]() {
        didSet {
            filteredContacts = contacts
        }
    }
    
    private let cellIdentifier = "ContactSearchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredContacts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let contact = filteredContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = filteredContacts[indexPath.row]
        contactSelector?.selected(contact: contact)
    }

}

extension ContactSearchResultsController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.characters.count > 0 {
            filteredContacts = contacts.filter {
                $0.fullName.range(of: searchText, options: .caseInsensitive) != nil
            }
        } else {
            filteredContacts = contacts
        }
        tableView.reloadData()
    }
}
