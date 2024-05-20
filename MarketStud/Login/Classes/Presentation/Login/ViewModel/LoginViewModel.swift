//
//  LoginModel.swift
//  StartIt
//
//  Created by Булат Мусин on 10.01.2024.
//

import Foundation

struct LoginUser: Encodable {
    var username: String
}

struct LoginModel: Encodable {
    var user: LoginUser
    var password: String
}
