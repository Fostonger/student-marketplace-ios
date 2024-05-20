//
//  Category.swift
//  StartIt
//
//  Created by Булат Мусин on 04.04.2024.
//

import Foundation
import CoreData

struct Category: Codable, Describable {
    public let id: Int64
    let description: String
    
    func asQueryItem() -> URLQueryItem? {
        guard id != -1 else { return nil }
        return URLQueryItem(name: "categoryId", value: "\(id)")
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public final class DBCategory: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var statusDescription: String?
}

extension Category: Persistable {
    
    typealias DBType = DBCategory
    
    static func from(_ dbModel: DBCategory) throws -> Category {
        Category(id: dbModel.id, description: dbModel.statusDescription ?? "")
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBCategory {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.statusDescription = description
        print(dbModel)
        return dbModel
    }
}
