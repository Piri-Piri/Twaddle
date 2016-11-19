//
//  AppDelegate.swift
//  Twaddle
//
//  Created by David Pirih on 11.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var contactImporter: ContactImporter?
    private var contactSyncer: ContextSyncer?
    private var contactsUploadSyncer: ContextSyncer?
    private var firebaseSyncer: ContextSyncer?
    
    private var firebaseStore: FirebaseStore?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        let mainContext = CoreDataHelper.shared.persistentContainer.viewContext
        let contactsContext = CoreDataHelper.shared.persistentContainer.newBackgroundContext()
        let firebaseContext = CoreDataHelper.shared.persistentContainer.newBackgroundContext()
        
        contactSyncer = ContextSyncer(main: mainContext, background: contactsContext)
        
        let firebaseStore = FirebaseStore(context: firebaseContext)
        self.firebaseStore = firebaseStore
        
        contactsUploadSyncer = ContextSyncer(main: contactsContext, background: firebaseContext)
        contactsUploadSyncer?.remoteStore = firebaseStore
        firebaseSyncer = ContextSyncer(main: mainContext, background: firebaseContext)
        firebaseSyncer?.remoteStore = firebaseStore
        
        contactImporter = ContactImporter(context: mainContext)
        //importContacts(context: contactsContext)
        
        let tabCtrl = UITabBarController()
        let vcData: [(UIViewController, UIImage, String)] = [
            (FavoritesViewController(), UIImage(named: "favorites_icon")!, "Favorites"),
            (ContactsViewController(), UIImage(named: "contact_icon")!, "Contacts"),
            (AllChatsViewController(), UIImage(named: "chat_icon")!, "Chats")
        ]
        let vcs = vcData.map {
            (vc: UIViewController, image: UIImage, title: String) -> UINavigationController in
            
            if var vc = vc as? ContextViewController {
                vc.context = mainContext
            }
            let navCtrl = UINavigationController(rootViewController: vc)
            navCtrl.tabBarItem.image = image
            navCtrl.tabBarItem.title = title
            return navCtrl
        }
        
        tabCtrl.viewControllers = vcs
        
        if firebaseStore.hasAuth() {
            
            firebaseStore.startSyncing()
            contactImporter?.listenForChanges()
            
            window?.rootViewController = tabCtrl
        } else {
            
            let signUpVC = SignUpViewController()
            signUpVC.remoteStore = firebaseStore
            signUpVC.rootViewController = tabCtrl
            signUpVC.contactImporter = contactImporter
            
            window?.rootViewController = signUpVC
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func importContacts(context: NSManagedObjectContext) {
        let dataSeeded = UserDefaults.standard.bool(forKey: "dataSeeded")
        guard !dataSeeded else { return }
        
        contactImporter?.fetch()
        
        UserDefaults.standard.set(true, forKey: "dataSeeded")
    }

}

