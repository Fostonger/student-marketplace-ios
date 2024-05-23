//
//  Chat.swift
//  MarketStud
//
//  Created by Булат Мусин on 19.05.2024.
//

import Foundation

struct Chat: Codable {
    let id: Int64
    let itemId: Int64
    let customerId: Int64
    
    private enum CodingKeys : String, CodingKey {
        case id, itemId = "item_id", customerId = "customer_id"
    }
}
