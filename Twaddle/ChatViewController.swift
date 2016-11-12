//
//  ChatViewController.swift
//  Twaddle
//
//  Created by David Pirih on 11.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {

    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let newMessageField = UITextView()
    
    fileprivate var sections = [Date : [Message]]()
    fileprivate var dates = [Date]()
    fileprivate var bottomConstraint: NSLayoutConstraint!
    fileprivate let cellIdentifier = "Cell"
    
    // TODO: may refactor (CoreDataHelper)?!?
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: may refactor to CoreDataHelper method
        do {
            let request: NSFetchRequest<Message> = Message.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if let msgs = try context?.fetch(request) {
                for msg in msgs {
                    addNew(message: msg)
                }
            }
        } catch {
            print("Error: Fetching messages failed: \(error.localizedDescription)")
        }
        
        let newMessageArea = UIView()
        newMessageArea.backgroundColor = UIColor.lightGray
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(newMessageField)
        newMessageField.isScrollEnabled = false
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.setContentHuggingPriority(251, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(751, for: .horizontal)
        
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        bottomConstraint = newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        let messageAreaConstraints: [NSLayoutConstraint] = [
            newMessageArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newMessageArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newMessageField.leadingAnchor.constraint(equalTo: newMessageArea.leadingAnchor, constant: 10),
            newMessageField.centerYAnchor.constraint(equalTo: newMessageArea.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: newMessageArea.trailingAnchor, constant: -10),
            newMessageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: newMessageField.centerYAnchor),
            newMessageArea.heightAnchor.constraint(equalTo: newMessageField.heightAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(messageAreaConstraints)
        
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.scrollToBottom()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func keyboardWillShow(notification: Notification) {
        
        updateBottomConstraint(notification: notification)
    }
    
    func keyboardWillHide(notification: Notification) {
        
        updateBottomConstraint(notification: notification)
    }
    
    func updateBottomConstraint(notification: Notification) {
        
        if let userInfo = notification.userInfo,
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            
            let newFrame = view.convert(frame, to: (UIApplication.shared.delegate?.window)!)
            bottomConstraint.constant = newFrame.origin.y - view.frame.height
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
            tableView.scrollToBottom()
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func sendTapped(button: UIButton) {
        guard let text = newMessageField.text, text.characters.count > 0 else {
            return
        }
            
        guard let context = context else {
            return
        }
        // TODO: may refactor to CoreDataHelper method
        guard let msg = NSEntityDescription
            .insertNewObject(forEntityName: "Message", into: context) as? Message else {
            return
        }
        msg.text = text
        msg.timestamp = NSDate()
        msg.incoming = false
        
        addNew(message: msg)
        // TODO: refactor to CoreDataHelper method
        do {
            try context.save()
        } catch {
            print("Error: Saving messages failed: \(error.localizedDescription)")
        }
        
        newMessageField.text = ""
        
        tableView.reloadData()
        tableView.scrollToBottom()
        
        view.endEditing(true)
    }
    
    func addNew(message: Message) {
        guard let date = message.timestamp as? Date else {
            return
        }
        
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: date)
        
        // TODO: name of var messages make sense (debug content)?!?
        var messages = sections[startDay]
        if messages == nil {
            dates.append(startDay)
            dates = dates.sorted {
                $0 < $1
            }
            
            messages = [Message]()
        }
        messages?.append(message)
        messages?.sort {
            ($0.timestamp as! Date) < ($1.timestamp as! Date)
        }
        sections[startDay] = messages
    }

}

extension ChatViewController: UITableViewDataSource {
    
    func getMessages(section: Int) -> [Message] {
        
        let date = dates[section]
        return sections[date]!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getMessages(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messages = getMessages(section: indexPath.section)
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        cell.messageLabel.text = message.text
        cell.incoming(incoming: message.incoming)
        
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            paddingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paddingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            paddingView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraint(equalTo: dateLabel.widthAnchor, constant: 10),
            view.heightAnchor.constraint(equalTo: paddingView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formatter.string(from: dates[section])
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }

}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
}

