//
//  Item.swift
//  StartIt
//
//  Created by Булат Мусин on 04.04.2024.
//

import Foundation
import CoreData

struct ItemDTO: Codable {
    let id: Int64
    let status_id: Int64
    let name: String
    let price: Int64
    let description: String
    let location_id: Int64
    let categories_ids: [Int64]
    let seller_id: Int64
}

public struct Item: Codable, Hashable, Describable {
    public let id: Int64
    let status: Status
    let name: String
    let price: Int64
    let description: String
    let location: Location
    let categories: [Category]
    let sellerId: Int64
    
    private enum CodingKeys : String, CodingKey {
        case id, name, price, description, status, location, categories, sellerId = "seller_id"
    }
    
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class DBItem: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var status: DBStatus
    @NSManaged var name: String
    @NSManaged var price: Int64
    @NSManaged var itemDescription: String
    @NSManaged var location: DBLocation
    @NSManaged var seller: Int64
}

extension Item: Persistable {
    
    typealias DBType = DBItem
    
    static func from(_ dbModel: DBItem) throws -> Item {
        Item(
            id: dbModel.id,
            status: try Status.from(dbModel.status),
            name: dbModel.name,
            price: dbModel.price,
            description: dbModel.itemDescription,
            location: try Location.from(dbModel.location),
            categories: [],
            sellerId: dbModel.seller
        )
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBItem {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.status = status.createDB(in: context)
        dbModel.name = name
        dbModel.price = price
        dbModel.itemDescription = description
        dbModel.location = location.createDB(in: context)
        dbModel.seller = sellerId
        return dbModel
    }
}
