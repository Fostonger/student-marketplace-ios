//
//  RegisterModel.swift
//  StartIt
//
//  Created by Булат Мусин on 11.01.2024.
//

import Foundation

struct RegisterUser: Encodable {
    var name: String
    var familyName: String
    var username: String
}

struct RegisterModel: Encodable {
    var user: RegisterUser
    var password: String
}
