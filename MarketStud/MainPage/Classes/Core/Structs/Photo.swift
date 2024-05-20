//
//  Photo.swift
//  StartIt
//
//  Created by Булат Мусин on 04.04.2024.
//

import Foundation
import CoreData

public struct Photo: Codable {
    let id: Int64
    let seqNumber: Int64
    let photoPath: String
    
    private enum CodingKeys : String, CodingKey {
        case id
        case seqNumber = "seq_number", photoPath = "photo_path"
    }
}

final class DBPhoto: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var itemId: DBItem
    @NSManaged var seqNumber: Int64
    @NSManaged var photoPath: String
}

extension Photo: Persistable {
    
    typealias DBType = DBPhoto
    
    static func from(_ dbModel: DBPhoto) throws -> Photo {
        Photo(
            id: dbModel.id,
            seqNumber: dbModel.seqNumber,
            photoPath: dbModel.photoPath
        )
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBPhoto {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.seqNumber = seqNumber
        dbModel.photoPath = photoPath
        return dbModel
    }
}

public struct PhotoWithImage: Hashable {
    public let id: Int64
    let photoMetadata: Photo
    let image: Data
    
    public static func == (lhs: PhotoWithImage, rhs: PhotoWithImage) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class DBPhotoWithImage: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var photoMetadata: DBPhoto
    @NSManaged var image: Data
}

extension PhotoWithImage: Persistable {
    
    typealias DBType = DBPhotoWithImage
    
    static func from(_ dbModel: DBPhotoWithImage) throws -> PhotoWithImage {
        PhotoWithImage(
            id: dbModel.id,
            photoMetadata: try Photo.from(dbModel.photoMetadata),
            image: dbModel.image
        )
    }
    
    func createDB(in context: NSManagedObjectContext) -> DBPhotoWithImage {
        let dbModel = createPersistanceObject(context)
        dbModel.id = id
        dbModel.photoMetadata = photoMetadata.createDB(in: context)
        dbModel.image = image
        return dbModel
    }
}
