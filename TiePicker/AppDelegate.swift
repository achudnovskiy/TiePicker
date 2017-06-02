//
//  AppDelegate.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-09-24.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

let kDataStorageUpdated:NSNotification.Name = NSNotification.Name(rawValue: "StorageUpdated")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var products:[Product] = []
    let dataStorage = DataStorage()
    
    let setupCloudkitSubscriptionKey = "SetupCloudkitSubscriptionKey"
    let setupRemoteNotificationKey = "SetupRemoteNotification"

    
    private func setupCloudkitSubscription() {
        let predicate = NSPredicate(value: true)
        let subscriptionOptions:CKQuerySubscriptionOptions = [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion]
        let subscription = CKQuerySubscription(recordType: "Product", predicate: predicate, options: subscriptionOptions)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (savedSubscription, error) in
            if error != nil {
                print("\(error)")
            }
            else {
                UserDefaults.standard.set(true, forKey: self.setupCloudkitSubscriptionKey)
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        if UserDefaults.standard.object(forKey: setupCloudkitSubscriptionKey) != nil {
            setupCloudkitSubscription()
        }
        
        if UserDefaults.standard.object(forKey: setupRemoteNotificationKey) != nil {
            //subscribe to silent push notification
            application.registerForRemoteNotifications()
        }
        
    
        
        dataStorage.getAllProductsFromCloud { (products) in
            print("Results from cloud \(products)")
        }
        
        dataStorage.getAllProductsFromDB()
        dataStorage.getAllProductsFromBackgroundDB()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if UserDefaults.standard.bool(forKey: "SkipTutorial") == false {
            mainStoryboard.instantiateViewController(withIdentifier: "IntroViewController")
        }
        
        return true
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("\(userInfo)")
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.standard.set(true, forKey: self.setupCloudkitSubscriptionKey)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error)")
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
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }

  
}

