//
//  Message.swift
//  MarketStud
//
//  Created by Булат Мусин on 19.05.2024.
//

import Foundation

struct Message: Codable {
    let chatId: Int64
    let senderId: Int64
    let message: String
    let seqNumber: Int64
}
