import Foundation
import CoreData

struct User: Codable, Hashable {
    let id: Int64
    let name: String
    let familyName: String
    let username: String
    let password: String
    
    private enum CodingKeys : String, CodingKey {
        case id, name, username, password
        case familyName = "family_name"
    }
}

final class DBUser: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var familyName: String
    @NSManaged var username: String
    @NSManaged var password: String
}

extension User: Persistable {
    
    typealias DBType = DBUser
    
    static func from(_ dbModel: DBUser) throws -> User {
        User(
            id: dbModel.id,
            name: dbModel.name,
            familyName: dbModel.familyName,
            username: dbModel.username,
            password: dbModel.password
        )
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBUser {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.name = name
        dbModel.familyName = familyName
        dbModel.username = username
        dbModel.password = password
        return dbModel
    }
}
