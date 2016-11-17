//
//  ContactImporter.swift
//  Twaddle
//
//  Created by David Pirih on 16.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import CoreData
import Contacts



class ContactImporter: NSObject {

    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func listenForChanges() {
        CNContactStore.authorizationStatus(for: .contacts)
        NotificationCenter.default.addObserver(self, selector: #selector(addressBookDidChange), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    func addressBookDidChange(notification: Notification) {
        fetch()
    }
    
    func fetch() {

        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            (granted, error) in
            
            self.context.perform {
                if granted {
                    do {
                        let (contacts, phoneNumbers) = self.fetchExisting()
                        
                        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                        try store.enumerateContacts(with: request, usingBlock: {
                            (cnContact, stop) in
                            
                            guard let contact = contacts[cnContact.identifier] ?? NSEntityDescription
                                .insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else { return }
                            
                            contact.firstName = cnContact.givenName
                            contact.lastName = cnContact.familyName
                            contact.contactId = cnContact.identifier
                            
                            for cnObject in cnContact.phoneNumbers {
                                let cnPhoneNumber = cnObject.value as CNPhoneNumber
                                guard let phoneNumber = phoneNumbers[cnPhoneNumber.stringValue] ?? NSEntityDescription
                                    .insertNewObject(forEntityName: "PhoneNumber", into: self.context) as? PhoneNumber else { continue }
                                
                                phoneNumber.kind = CNLabeledValue<NSString>.localizedString(forLabel: cnObject.label!)
                                phoneNumber.value = self.formatPhoneNumber(number: cnPhoneNumber)
                                phoneNumber.contact = contact
                            }
                            if contact.isInserted {
                                contact.favorite = true
                            }
                        })
                        try self.context.save()
                    } catch let error as NSError {
                        print("Error: Fetching/Saving contacts: \(error)")
                    } catch {
                        print("Error: Fetching/Saving contacts: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    private func fetchExisting() -> (contacts: [String : Contact], phoneNumbers: [String : PhoneNumber]) {
        
        var contacts = [String : Contact]()
        var phoneNumbers = [String : PhoneNumber]()
        do {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            let contactsResult = try self.context.fetch(request)
            for contact in contactsResult {
                contacts[contact.contactId!] = contact
                for phoneNumber in contact.phoneNumbers! {
                    phoneNumbers[(phoneNumber as! PhoneNumber).value!] = phoneNumber as? PhoneNumber
                }
            }
        } catch {
            print("Error: Fetching existing contacts failed: \(error.localizedDescription)")
        }
        
        return (contacts, phoneNumbers)
    }
    
    func formatPhoneNumber(number: CNPhoneNumber) -> String {
        
        return (number.stringValue as NSString)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
    
}
