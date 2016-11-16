//
//  NewGroupViewController.swift
//  Twaddle
//
//  Created by David Pirih on 13.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {

    var context: NSManagedObjectContext?
    var chatCreationDelegate: ChatCreationDelegate?
    
    private let subjectField = UITextField()
    private let characterNumberLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Group"
        
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        updateNextButton(forCharCount: 0)
        
        subjectField.placeholder = "Group Subject"
        subjectField.delegate = self
        subjectField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subjectField)
        updateCharacterLabel(forCharCount: 0)
        
        characterNumberLabel.textColor = UIColor.gray
        characterNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(characterNumberLabel)
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.lightGray
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(bottomBorder)
        
        
        let constraints: [NSLayoutConstraint] = [
            subjectField.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20),
            subjectField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            subjectField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
       
            bottomBorder.widthAnchor.constraint(equalTo: subjectField.widthAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: subjectField.bottomAnchor),
            bottomBorder.leadingAnchor.constraint(equalTo: subjectField.leadingAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1),
            
            characterNumberLabel.centerYAnchor.constraint(equalTo: subjectField.centerYAnchor),
            characterNumberLabel.trailingAnchor.constraint(equalTo: subjectField.layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cancelTapped() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func nextTapped() {
        
        guard let context = context, let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as? Chat else { return }
        chat.name = subjectField.text
     
        let newGroupPartiVC = NewGroupParticipantsViewController()
        newGroupPartiVC.context = context
        newGroupPartiVC.chat = chat
        newGroupPartiVC.chatCreationDelegate = chatCreationDelegate
        
        navigationController?.pushViewController(newGroupPartiVC, animated: true)
    }
    
    func updateCharacterLabel(forCharCount charCount: Int) {
        
        characterNumberLabel.text = String(25 - charCount)
    }
    
    func updateNextButton(forCharCount charCount: Int) {
        
        if charCount == 0 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}

extension NewGroupViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharCount = textField.text?.characters.count ?? 0
        let newLength = currentCharCount + string.characters.count - range.length
        
        if newLength <= 25 {
            updateCharacterLabel(forCharCount: newLength)
            updateNextButton(forCharCount: newLength)
            return true
        }
        
        return false
    }
}
