//
//  APIEndpoint.swift
//  StartIt
//
//  Created by Булат Мусин on 27.10.2023.
//

import Foundation
import Alamofire

protocol Endpoint {
    func getEndpoint() -> String
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var authRequired: Bool { get }
    var urlString: String { get }
}

extension Endpoint {
    var urlString: String { "http://127.0.0.1:8083/" + getEndpoint() }
    var method: HTTPMethod      { .get }
    var authRequired: Bool      { true }
    var headers: HTTPHeaders    { [.accept("application/json")] }
}

protocol AdditionalQuery {
    var queryItems: [URLQueryItem] { get }
}

func +(lhs: Endpoint, rhs: AdditionalQuery) -> Endpoint {
    guard var components = URLComponents(string: lhs.urlString) else {
        return lhs
    }
    components.queryItems = rhs.queryItems
    if let urlString = components.percentEncodedQuery, components.queryItems?.count != 0 {
        return BareUrlEndpoint(urlString: urlString, authRequired: lhs.authRequired, headers: lhs.headers, method: lhs.method)
    }
    return lhs
}

struct BareUrlEndpoint: Endpoint {
    let urlString: String
    let authRequired: Bool
    let headers: HTTPHeaders
    let method: HTTPMethod
    
    init(urlString: String, authRequired: Bool = true, headers: HTTPHeaders = [.accept("application/json")], method: HTTPMethod = .get) {
        self.urlString = urlString
        self.authRequired = authRequired
        self.headers = headers
        self.method = method
    }
    
    func getEndpoint() -> String { "" }
    
}

enum AuthEndpoint: Endpoint {
    case login
    case register
    
    func getEndpoint() -> String {
        switch self {
        case .login:
            return endpointBase + "login"
        case .register:
            return endpointBase + "register"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        }
    }
    
    var authRequired: Bool { false }
    
    private var endpointBase: String { "api/v1/auth/" }
}

enum CategoryEndpoint: Endpoint {
    case categories
    
    func getEndpoint() -> String {
        switch self {
        case .categories:
            return "api/v1/category/all"
        }
    }
}

enum LocationEndpoint: Endpoint {
    case location
    
    func getEndpoint() -> String {
        switch self {
        case .location:
            return "api/v1/location/all"
        }
    }
}

enum StatusEndpoint: Endpoint {
    case status
    
    func getEndpoint() -> String {
        switch self {
        case .status:
            return "api/v1/status/all"
        }
    }
}

enum ProfileEndpoint: Endpoint {
    case user(id: Int64)
    
    func getEndpoint() -> String {
        switch self {
        case .user(let id):
            return baseRequest + "\(id)"
        }
    }
    
    private var baseRequest: String { "api/v1/user/" }
}

enum ItemEndpoint: Endpoint {
    case saveItem
    case updateItem
    case updateImage
    case loadImage
    case fetchImage(itemId: Int64)
    case fetchItem(page: Int, filter: SearchFilter)
    case fetchOneItem(itemId: Int64)
    
    func getEndpoint() -> String {
        switch self {
        case .updateItem:
            return baseRequest + "update"
        case .saveItem:
            return baseRequest + "create"
        case .loadImage:
            return "api/v1/objects"
        case .updateImage:
            return "api/v1/objects/update"
        case .fetchImage(let itemId):
            return "api/v1/objects/download?itemId=\(itemId)"
        case .fetchItem(let page, let filter):
            return baseRequest + "search?\(filter.toQuery())&page=\(page)"
        case .fetchOneItem(let itemId):
            return baseRequest + "getInfo?itemId=\(itemId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .saveItem, .updateItem, .loadImage, .updateImage:
            return .post
        case .fetchImage, .fetchItem, .fetchOneItem:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .saveItem, .updateItem, .fetchItem, .fetchOneItem:
            return [.accept("application/json")]
        case .fetchImage:
            return []
        case .loadImage, .updateImage:
            return [.accept("*/*"), .contentType("multipart/form-data")]
        }
    }
    
    private var baseRequest: String { "api/v1/item/" }
}

enum ChatEndpoint: Endpoint {
    case createChat
    case sendMessage
    case pollMessages(userId: Int64, lastKnownMessageId: Int64)
    case getMessages(chatId: Int64, page: Int)
    case getChats(userId: Int64, page: Int)
    
    func getEndpoint() -> String {
        switch self {
        case .createChat:
            return baseRequest + "create"
        case .sendMessage:
            return baseRequest + "sendMessage"
        case .pollMessages(let userId, let lastKnownMessageId):
            return baseRequest + "pollMessages?userId=\(userId)&lastMessageId=\(lastKnownMessageId)"
        case .getMessages(let chatId, let page):
            return baseRequest + "messages/\(chatId)?page=\(page)"
        case .getChats(let userId, let page):
            return baseRequest + "user/\(userId)?page=\(page)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMessages, .getChats, .pollMessages:
            return .get
        case .sendMessage, .createChat:
            return .post
        }
    }
    
    private var baseRequest: String { "api/v1/chat/" }
}
