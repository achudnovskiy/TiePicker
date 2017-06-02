//
//  DataStorage.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-10-05.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class DataStorage: NSObject {
    
    // MARK: - CloudKit code
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    public func getAllProductsFromCloud(completionBlock:@escaping ([Product])->Void) {
        
        let query = CKQuery(recordType: "Product", predicate: NSPredicate(value: true))
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            var result:[Product] = []

            if (error != nil || records == nil) {
                NSLog("error in fetching cloudkit. Error info:\(error)")
            }
            else {
                
                for record:CKRecord in records! {
                    var image:UIImage?
                    if let asset = record.object(forKey: "imageData") as? CKAsset {
                        if let data = NSData(contentsOf: asset.fileURL) {
                            image = UIImage(data: data as Data)
                        }
                    }
                    let webUrl:String? = record.object(forKey: "webUrl") as? String
                    
                    if image != nil && webUrl != nil {
                        result.append(Product(image: image!, url: webUrl!))
                    }
                }
            }
            
            completionBlock(result)
        }
    }
    
    public func getAllProductsFromDB() {

        let query:NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        do {
            let results = try persistentContainer.viewContext.fetch(query)
            print("Results \(results)")
        } catch {
            print ("Error with request \(error)")
        }
    }
    
    public func getAllProductsFromBackgroundDB() {
        persistentContainer.viewContext.performAndWait {
            let query:NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            do {
                let results = try self.backgroundContext.fetch(query)
                print("Results \(results)")
                
            } catch {
                print ("Error with request \(error)")
            }
        }
    }
    
    
    // MARK: - Core Data stack
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TiePicker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
