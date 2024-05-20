//
//  Storage.swift
//  StartIt
//
//  Created by Булат Мусин on 02.04.2024.
//

import Foundation
import CoreDataManager
import CoreData

protocol IStorage {
    
    func fetch<Model: Persistable> (
        _ modelType: Model.Type,
        predicate: NSPredicate?,
        limit: Int?
    ) -> [Model]
    
    func save<Model: Persistable & Describable>(_ objects: [Model])
    
    func remove<Model: Persistable>(_ object: Model.Type, predicate: NSPredicate?)
    
    func replaceAll<Model: Persistable>(_ objects: [Model])
}

final class Storage: NSObject, IStorage, NSFetchedResultsControllerDelegate {
    
    // Properties
    private let cdm: CoreDataManager
    
    // MARK: - Initialize
    
    init(cdm: CoreDataManager = CoreDataManager.sharedInstance) {
        self.cdm = cdm
    }
    
    // MARK: - IStorage
    
    func fetch<Model>(_ modelType: Model.Type, predicate: NSPredicate?, limit: Int?) -> [Model] where Model : Persistable {
        let context = cdm.mainContext
        let fetchRequest = NSFetchRequest<Model.DBType>(entityName: "DBStatus")
        
        var result: [Model] = []
        context.performAndWait {
            do {
                let fetched = try context.fetch(fetchRequest)
                result = try fetched.map(Model.from)
            } catch {
                print("ERROR! Coult not fetch \(fetchRequest)")
            }
        }
        return result
    }
    
    func save<Model: Persistable & Describable>(_ objects: [Model]) {
        let context = cdm.mainContext
        for item in objects {
            let predicate = NSPredicate(format: "identifier IN %@", item.id)
            let itemCopy = item
            
            context.performAndWait {
                self.removeAllObjects(Model.self, with: predicate, in: context)
            }
            try! context.saveIfChanged()
        }
    }
    
    func remove<Model: Persistable>(_ object: Model.Type, predicate: NSPredicate?) {
        let context = cdm.mainContext
        
        context.performAndWait {
            self.removeAllObjects(Model.self, with: predicate, in: context)
        }
        try! context.saveIfChanged()
    }
    
    func replaceAll<Model: Persistable>(_ objects: [Model]) {
        remove(Model.self)
    }
}

private extension Storage {
    func removeAllObjects<Model: Persistable>(
        _ modelType: Model.Type,
        with predicate: NSPredicate?,
        in context: NSManagedObjectContext
    ) {
        let fetchRequest = NSFetchRequest<Model.DBType>(entityName: "DBStatus")
        
        do {
            let objects = try context.fetch(fetchRequest)
            objects.forEach { context.delete($0) }
        } catch {
            print("ERROR! Failed to remove objects \(Model.self): \(error)")
        }
    }
}

extension IStorage {
    
    func remove<Model: Persistable>(_ modelType: Model.Type) {
        remove(modelType, predicate: nil)
    }
}
