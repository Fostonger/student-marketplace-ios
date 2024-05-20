//
//  StartItError.swift
//  StartIt
//
//  Created by Булат Мусин on 08.01.2024.
//

import Foundation
import Alamofire

enum APIError: Error {
    case auth(message: String)
    case dataCorrupted(message: String)
    case download(message: String)
    case request(message: String)
    case other(message: String)
    case statusCode(message: String)
    case network(error: AFError)
    
    static func map(_ error: Error) -> APIError {
        if let afError = error as? AFError {
            return .network(error: afError)
        }
        return (error as? APIError) ?? .other(message: error.localizedDescription)
    }
}
