//
//  AllChatsViewController.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer {

    // TODO: may refactor (CoreDataHelper)?!?
    var context: NSManagedObjectContext?
    
    // TODO: may refactor (CoreDataHelper)?!?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Chat>?
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "MessageCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new-chat"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(newChat))
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
       
        fillViewWith(tableView)
        
        // TODO: may refactor to CoreDataHelper method
        if let context = context {
            let request: NSFetchRequest<Chat> = Chat.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
            
            fetchedResultsDelegate =
                TableViewFetchedResultsDelegate(tableView: tableView,
                                                displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("Error: Fetching chats failed: \(error.localizedDescription)")
            }
        }
        
        // TODO: remove fake data (later)
        fakeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func newChat() {
        
        let newChatVC = NewChatViewController()
        newChatVC.context = context
        
        let navCtrl = UINavigationController(rootViewController: newChatVC)
        present(navCtrl, animated: true, completion: nil)
    }
    
    func fakeData() {
        
        guard let context = context else {
            return
        }
        
        // TODO: may refactor to CoreDataHelper method
        guard let chat = NSEntityDescription
            .insertNewObject(forEntityName: "Chat", into: context) as? Chat else {
                return
        }
    }
    
    func configure(cell: UITableViewCell, at indexPatch: IndexPath) {
        
        let cell = cell as! ChatCell
        guard let chat = fetchedResultsController?.object(at: indexPatch) else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = "David"
        cell.dateLabel.text = formatter.string(from: Date())
        cell.messageLabel.text = "Hey!"
    }
}

extension AllChatsViewController: UITableViewDataSource {

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
    
}

extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let chat = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        
    }
    
}
