//
//  AppDelegate.swift
//  Twaddle
//
//  Created by David Pirih on 11.11.16.
//  Copyright © 2016 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let allChatsVC = AllChatsViewController()
        let navCrtl = UINavigationController(rootViewController: allChatsVC)
        window?.rootViewController = navCrtl
        
        let context = CoreDataHelper.shared.persistentContainer.viewContext
        allChatsVC.context = context
        
        // TODO: remove fake data
        fakeData(context: context)
        
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

    func fakeData(context: NSManagedObjectContext) {
        let dataSeeded = UserDefaults.standard.bool(forKey: "dataSeeded")
        guard !dataSeeded else {
            return
        }
        
        let people = [("Vera", "Pirih"), ("Alisha", "Pirih"), ("Malou", "Pirih"), ("Kevin", "Pirih")]
        for person in people {
            let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            contact.firstName = person.0
            contact.lastName = person.1
        }
        
        // TODO: refactor to CoreDataHelper method
        do {
            try context.save()
        } catch {
            print("Error: Saving contacts (fake data) failed: \(error.localizedDescription)")
        }
        
        UserDefaults.standard.set(true, forKey: "dataSeeded")
    }
    

}

