//
//  AllChatsViewController.swift
//  Twaddle
//
//  Created by David Pirih on 12.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer, ChatCreationDelegate {

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
        tableView.tableHeaderView = createHeader()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func newChat() {
        
        let newChatVC = NewChatViewController()
        
        // * child context for chats *
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        
        newChatVC.context = chatContext
        newChatVC.chatCreationDelegate = self
        
        let navCtrl = UINavigationController(rootViewController: newChatVC)
        present(navCtrl, animated: true, completion: nil)
    }
    
    func configure(cell: UITableViewCell, at indexPatch: IndexPath) {
        
        let cell = cell as! ChatCell
        guard let chat = fetchedResultsController?.object(at: indexPatch) else { return }
        guard let contact = chat.participants?.anyObject() as? Contact else { return }
        guard let lastMessage = chat.lastMessage,
            let timestamp = lastMessage.timestamp,
            let text = lastMessage.text else { return }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = contact.fullName
        cell.dateLabel.text = formatter.string(from: timestamp as Date)
        cell.messageLabel.text = text
    }
    
    func created(chat: Chat, in context: NSManagedObjectContext) {
        
        let chatVC = ChatViewController()
        chatVC.context = context
        chatVC.chat = chat
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func createHeader() -> UIView {
        
        let header = UIView()
        let newGroupButton = UIButton()
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(newGroupButton)
        
        newGroupButton.setTitle("New Group", for: .normal)
        newGroupButton.setTitleColor(view.tintColor, for: .normal)
        newGroupButton.addTarget(self, action: #selector(newGroupTapped), for: .touchUpInside)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(border)
        
        border.backgroundColor = UIColor.lightGray
        
        
        let constraints: [NSLayoutConstraint] = [
            newGroupButton.heightAnchor.constraint(equalTo: header.heightAnchor),
            newGroupButton.trailingAnchor.constraint(equalTo: header.layoutMarginsGuide.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        
        return header
    }
    
    func newGroupTapped() {
        let newGroupVC = NewGroupViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        newGroupVC.context = chatContext
        newGroupVC.chatCreationDelegate = self
        
        
        let navVC = UINavigationController(rootViewController: newGroupVC)
        present(navVC, animated: true, completion: nil)
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
        
        guard let chat = fetchedResultsController?.object(at: indexPath) else { return }
        let chatVC = ChatViewController()
        chatVC.context = context
        chatVC.chat = chat
        
        navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
