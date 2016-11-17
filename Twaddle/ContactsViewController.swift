//
//  ContactsViewController.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class ContactsViewController: UIViewController, ContextViewController, TableViewFetchedResultsDisplayer, ContactSelector {

    var context: NSManagedObjectContext?
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Contact>?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    private var searchController: UISearchController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = "All Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(newContact))
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(tableView)
        
        if let context = context {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
            request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error: Fetching contact failed: \(error.localizedDescription)")
            }
        }
        
        let resultsVC = ContactSearchResultsController()
        resultsVC.contactSelector = self
        resultsVC.contacts = (fetchedResultsController?.fetchedObjects)!
        
        searchController = UISearchController(searchResultsController: resultsVC)
        searchController?.searchResultsUpdater = resultsVC
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func newContact() {
        
        let contactVC = CNContactViewController(forNewContact: nil)
        contactVC.delegate = self
        navigationController?.pushViewController(contactVC, animated: true)
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else { return }
        cell.textLabel?.text = contact.fullName
    }
    
    func selected(contact: Contact) {
        
        guard let id = contact.contactId else { return }
        let store = CNContactStore()
        let cnContact: CNContact
        do {
           cnContact = try store.unifiedContact(withIdentifier: id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            print("Error: Selecting contact failed: \(error.localizedDescription)")
            return
        }
        let contactVC = CNContactViewController(for: cnContact)
        contactVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(contactVC, animated: true)
        searchController?.isActive = false
    }

}

extension ContactsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = fetchedResultsController?.sections else { return nil }
        return sections[section].name
    }
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else { return }
        selected(contact: contact)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ContactsViewController: CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        
        if contact == nil {
            let _ = navigationController?.popViewController(animated: true)
        }
    }
}
