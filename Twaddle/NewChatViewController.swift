//
//  NewChatViewController.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController {

    // TODO: may refactor (CoreDataHelper)?!?
    var context: NSManagedObjectContext?
    
    // TODO: may refactor (CoreDataHelper)?!?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Contact>?
    
    fileprivate var tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(cancel))
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        let tableViewContraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(tableViewContraints)
        
        if let context = context {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "sortLetter",
                                                                  cacheName: "NewChatViewController")
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error: Fetching contacts failed: \(error.localizedDescription)")
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        guard let contact = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        cell.textLabel?.text = contact.fullName
    }
}

extension NewChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = fetchedResultsController?.sections else {
            return nil
        }
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
}

extension NewChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let contact = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        
    }
}

extension NewChatViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)
            configure(cell: cell!, at: indexPath!)
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }
}
