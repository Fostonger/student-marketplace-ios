//
//  AuthModel.swift
//  StartIt
//
//  Created by Булат Мусин on 08.01.2024.
//

import Foundation

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let userId: Int64
    let tokenLifetime: Int32?
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenLifetime = "token_lifetime"
        case userId = "user_id"
    }
}

struct Credentials: Codable {
    let password: String
    let login: String
}
