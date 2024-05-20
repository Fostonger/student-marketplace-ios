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
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .saveItem, .updateItem, .loadImage, .updateImage:
            return .post
        case .fetchImage, .fetchItem:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .saveItem, .updateItem, .fetchItem:
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
    case getMessages
    case getChats
    
    func getEndpoint() -> String {
        switch self {
        case .createChat:
            return baseRequest + "create_chat"
        case .sendMessage:
            return baseRequest + "send_message"
        case .getMessages:
            return baseRequest + "get_messages"
        case .getChats:
            return baseRequest + "get_chats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createChat, .sendMessage:
            return .post
        case .getMessages, .getChats:
            return .post
        }
    }
    
    private var baseRequest: String { "chat/" }
}
