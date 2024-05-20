//
//  Status.swift
//  StartIt
//
//  Created by Булат Мусин on 04.04.2024.
//

import Foundation
import CoreData

struct Status: Codable, Describable, URLQueryRepresentable {
    public let id: Int64
    let description: String
    
    func asQueryItem() -> URLQueryItem? {
        guard id != -1 else { return nil }
        return URLQueryItem(name: "status", value: "\(id)")
    }
    
    static func == (lhs: Status, rhs: Status) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public final class DBStatus: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var statusDescription: String?
}

extension Status: Persistable {
    
    typealias DBType = DBStatus
    
    static func from(_ dbModel: DBStatus) throws -> Status {
        Status(id: dbModel.id, description: dbModel.statusDescription ?? "")
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBStatus {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.statusDescription = description
        return dbModel
    }
}
