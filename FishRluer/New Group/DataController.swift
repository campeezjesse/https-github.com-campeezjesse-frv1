//
//  DataController.swift
//  FishRuler
//
//  Created by user1 on 7/10/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    
    var persistentContainer = NSPersistentContainer()
    var managedObjectContext: NSManagedObjectContext
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
   
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Fish_Ruler")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
        let fish = NSEntityDescription.insertNewObject(forEntityName: "Fish", into: managedObjectContext) as! Fish
    }
}
