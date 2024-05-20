//
//  AppContext.swift
//  StartIt
//
//  Created by Булат Мусин on 27.10.2023.
//

import Foundation

class AppContext: ObservableObject {
    let user: User
    @Published var statuses: [Status] = []
    @Published var categories: [Category] = []
    @Published var locations: [Location] = []
    
    init(user: User, statuses: [Status] = [], categories: [Category] = [], locations: [Location] = []) {
        self.user = user
        self.statuses = statuses
        self.categories = categories
        self.locations = locations
    }
}
