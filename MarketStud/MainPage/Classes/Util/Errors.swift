//
//  Errors.swift
//  StartIt
//
//  Created by Булат Мусин on 29.10.2023.
//

import Foundation

enum ItemCreationError: Error {
    // Throw when an invalid password is entered
    case photoNotFound
    
    public var description: String {
        switch self {
        case .photoNotFound:
            return "Photo must be set in order to send it."
        }
    }
}
