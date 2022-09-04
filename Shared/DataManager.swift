//
//  DataManager.swift
//  TeamUp
//
//  Created by Noé Duran on 9/3/22.
//

import Foundation
import CoreData
import CloudKit

class PersistenceController: ObservableObject {

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "DataModel")
        
        guard let defaultDesctiption = container.persistentStoreDescriptions.first else {
            fatalError()
        }

        let publicOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.noeduran.TeamUpCD")
        publicOptions.databaseScope = .public
        defaultDesctiption.cloudKitContainerOptions = publicOptions

        defaultDesctiption.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        defaultDesctiption.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.persistentStoreDescriptions = [defaultDesctiption]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print(error)
        }
    }
}
