//
//  NewGroupParticipantsViewController.swift
//  Twaddle
//
//  Created by David Pirih on 14.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {

    var context: NSManagedObjectContext?
    var chat: Chat?
    var chatCreationDelegate: ChatCreationDelegate?
    
    fileprivate var searchField: UITextField!
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    
    fileprivate var displayedContacts = [Contact]()
    fileprivate var selectedContacts = [Contact]()
    fileprivate var allContacts = [Contact]()
    
    fileprivate var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Participants"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createChat))
        createButton(show: false)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchField = createSearchField()
        searchField.delegate = self
        tableView.tableHeaderView = searchField
        
        fillViewWith(tableView)
        
        if let context = context {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
            request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
            
            do {
                let contacts = try context.fetch(request)
                allContacts = contacts
            } catch {
                print("Error: Fetching contacts failed: \(error.localizedDescription)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func createSearchField() -> UITextField {
        
        let searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        searchField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        searchField.placeholder = "Type contact name"
        
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchField.leftView = holderView
        searchField.leftViewMode = .always
        
        let image = UIImage(named: "contact_icon")?.withRenderingMode(.alwaysTemplate)
        
        let contactImage = UIImageView(image: image)
        contactImage.tintColor = UIColor.darkGray
        
        holderView.addSubview(contactImage)
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            contactImage.widthAnchor.constraint(equalTo: holderView.widthAnchor, constant: -20),
            contactImage.heightAnchor.constraint(equalTo: holderView.heightAnchor, constant: -20),
            contactImage.centerXAnchor.constraint(equalTo: holderView.centerXAnchor),
            contactImage.centerYAnchor.constraint(equalTo: holderView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return searchField
    }
    
    fileprivate func createButton(show: Bool) {
        
        if show {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    fileprivate func endSearch() {
        displayedContacts = selectedContacts
        tableView.reloadData()
    }
    
    func createChat() {
        
        guard let chat = chat, let context = context else { return }
        chat.participants = NSSet(array: selectedContacts)
        chatCreationDelegate?.created(chat: chat, in: context)
        
        dismiss(animated: false, completion: nil)
    }
    
}

extension NewGroupParticipantsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = displayedContacts[indexPath.row].fullName
        cell.selectionStyle = .none
        
        return cell
    }
    
}

extension NewGroupParticipantsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isSearching else { return }
        let contact = displayedContacts[indexPath.row]
        guard !selectedContacts.contains(contact) else { return }
        
        selectedContacts.append(contact)
        allContacts.remove(at: allContacts.index(of: contact)!)
        searchField.text = ""
        endSearch()
        
        createButton(show: true)
    }
}

extension NewGroupParticipantsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        isSearching = true
        guard let currentText = textField.text else {
            endSearch()
            return true
        }
        
        let text = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if text.characters.count == 0 {
            endSearch()
            return true
        }
        
        displayedContacts = allContacts.filter {
            contact in
            
            let matched = contact.fullName.range(of: text, options: [.caseInsensitive]) != nil
            return matched
        }
        tableView.reloadData()
        return true
    }
    
}
