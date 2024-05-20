//
//  FetchAPI.swift
//  StartIt
//
//  Created by Булат Мусин on 10.01.2024.
//

import Foundation
import Combine

protocol Fetchable {
    func fetch<U: Decodable>(with endpoint: Endpoint, parameters: any Encodable, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ())
    func fetch<U: Decodable>(with endpoint: Endpoint, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ())
    func uploadPhoto(with endpoint: Endpoint, data: Data, itemId: Int64, completion: @escaping (Result<PhotoUploadResponse, APIError>) -> ())
}
