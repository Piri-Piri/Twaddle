//
//  FavoritesViewController.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class FavoritesViewController: UIViewController, TableViewFetchedResultsDisplayer, ContextViewController {

    var context: NSManagedObjectContext?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Contact>?
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "FavoritesCell"
    
    fileprivate let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Favorites"
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(tableView)
        
        if let context = context {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.predicate = NSPredicate(format: "storageId != nil AND favorite = true")
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
            request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error: Fetching contact failed: \(error.localizedDescription)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAll))
        } else {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = nil
            
            guard let context = context, context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                print("Error: Saving favorites failed: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAll() {
        
        guard let contacts = fetchedResultsController?.fetchedObjects else { return }
        for contact in contacts {
            context?.delete(contact)
        }
    }

    func configure(cell: UITableViewCell, at indexPatch: IndexPath) {
    
        guard let contact = fetchedResultsController?.object(at: indexPatch) else { return }
        guard let cell = cell as? FavoriteCell else { return }
        
        cell.textLabel?.text = contact.fullName
        cell.detailTextLabel?.text = contact.status ?? "*** no status ***"
        cell.phoneTypeLabel.text = (contact.phoneNumbers?.filter({
            number in
            
            guard let number = number as? PhoneNumber else { return false }
            return number.registered
        }).first as? PhoneNumber)?.kind
        
        cell.accessoryType = .detailButton
    }

}

extension FavoritesViewController: UITableViewDataSource {
    
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

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else { return }
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        
        let chat =
            Chat.existing(directWith: contact, in: chatContext) ?? Chat.new(directWith: contact, in: chatContext)
        
        let chatVC = ChatViewController()
        chatVC.context = chatContext
        chatVC.chat = chat
        chatVC.hidesBottomBarWhenPushed = true
        
        let _ = navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else { return }
        guard let id = contact.contactId else { return }
        
        let cnContact: CNContact
        do {
            cnContact = try store.unifiedContact(withIdentifier: id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            return
        }
        let contactVC = CNContactViewController(for: cnContact)
        contactVC.hidesBottomBarWhenPushed = true
        
        let _ = navigationController?.pushViewController(contactVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else { return }
        contact.favorite = false
    }
}
