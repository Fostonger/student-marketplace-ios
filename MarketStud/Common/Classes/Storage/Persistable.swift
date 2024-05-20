//
//  Persistable.swift
//  StartIt
//
//  Created by Булат Мусин on 02.04.2024.
//

import Foundation
import CoreData

protocol Persistable {
    
    associatedtype DBType: NSManagedObject
    
    static func from(_ dbModel: DBType) throws -> Self
    
    @discardableResult
    func createDB(in context: NSManagedObjectContext) -> DBType
}

extension Persistable {
    func createPersistanceObject(_ context: NSManagedObjectContext) -> DBType {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: "\(type(of: DBType.self))", into: context) as? DBType else {
            fatalError("Could not create persistance object with DBType \(DBType.self)")
        }
        
        return entity
    }
    
    static func from(_ dbModel: DBType?) throws -> Self? {
        guard let dbModel = dbModel else { return nil }
        
        return try self.from(dbModel)
    }
}
