//
//  ChatViewController.swift
//  Twaddle
//
//  Created by David Pirih on 11.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    private let tableView = UITableView()
    
    fileprivate var messages = [Message]()
    fileprivate let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var localIncoming = true
        for i in 0...10 {
            let m = Message()
            //m.text = String(i)
            m.text = "This is a longer test message."
            m.incoming = localIncoming
            localIncoming = !localIncoming
            messages.append(m)
        }
        
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatCell
        cell.messageLabel.text = message.text
        cell.incoming(incoming: message.incoming)
        
        return cell
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    
    
}

