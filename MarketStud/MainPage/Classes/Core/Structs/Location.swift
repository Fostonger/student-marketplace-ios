//
//  Location.swift
//  StartIt
//
//  Created by Булат Мусин on 04.04.2024.
//

import Foundation
import CoreData

struct Location: Codable, Describable {
    public var id: Int64
    let description: String
    
    func asQueryItem() -> URLQueryItem? {
        guard id != -1 else { return nil }
        return URLQueryItem(name: "locationId", value: "\(id)")
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public final class DBLocation: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var locationDescription: String?
}

extension Location: Persistable {
    
    typealias DBType = DBLocation
    
    static func from(_ dbModel: DBLocation) throws -> Location {
        Location(id: dbModel.id, description: dbModel.locationDescription ?? "")
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBLocation {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.locationDescription = description
        return dbModel
    }
}
