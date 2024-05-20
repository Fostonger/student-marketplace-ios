//
//  APIClient.swift
//  StartIt
//
//  Created by Булат Мусин on 27.10.2023.
//

import Alamofire
import Foundation
import Combine

protocol APIClient: Downloadable, Fetchable {}

final class MIAPIClient<AppService>: APIClient where AppService: AuthStateService {
    let credentialsProvider: AppService
    private let encoder: ParameterEncoder
    private let client: Session
    private var lock: NSLock
    
    public init(with client: Session, encoder: ParameterEncoder? = nil, credentialsProvider: AppService) {
        self.credentialsProvider = credentialsProvider
        
        let defaultEncoder = JSONParameterEncoder()
        defaultEncoder.encoder.outputFormatting = .prettyPrinted
        defaultEncoder.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder ?? defaultEncoder
        self.client = client
        self.lock = NSLock()
    }
    
    public func fetch<U: Decodable>(with endpoint: Endpoint, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ()) {
        fetch(with: endpoint, parameters: Optional<Int>.none, responseType: responseType, completion: completion)
    }
    
    public func fetch<U: Decodable>(with endpoint: Endpoint, parameters: any Encodable, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ()) {
        lock.lock()
        guard !endpoint.authRequired || credentialsProvider.token != nil else {
            lock.unlock()
            refreshAuthAndRetry(endpoint: endpoint, parameters: parameters, responseType: responseType, completion: completion)
            return
        }
        
        var headers = endpoint.headers
        if endpoint.authRequired, let token = credentialsProvider.token {
            headers.add(.authorization(bearerToken: token))
        }
        lock.unlock()
        if endpoint.method != .get {
            client.request(endpoint.urlString, method: endpoint.method, parameters: parameters, encoder: encoder, headers: headers)
                .validate()
                .responseDecodable(of: U.self) { [weak self] response in
                    self?.handleResponse(response, endpoint: endpoint, parameters: parameters, responseType: responseType, completion: completion)
                }
        }
        else {
            client.request(endpoint.urlString, method: endpoint.method, headers: headers)
                .validate()
                .responseDecodable(of: U.self) { [weak self] response in
                    self?.handleResponse(response, endpoint: endpoint, parameters: parameters, responseType: responseType, completion: completion)
                }
        }
    }
    
    private func refreshAuthAndRetry<T: Encodable, U: Decodable>(endpoint: Endpoint, parameters: T, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ()) {
        withTryAuth { [weak self] result in
            switch result {
            case .success:
                self?.fetch(with: endpoint, parameters: parameters, responseType: responseType, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func handleResponse<T: Encodable, U: Decodable>(_ response: AFDataResponse<U>, endpoint: Endpoint, parameters: T, responseType: U.Type, completion: @escaping (Result<U, APIError>) -> ()) {
        switch response.result {
        case .success(let value):
            if let authResponse = value as? AuthResponse {
                lock.lock()
                credentialsProvider.setToken(
                    authResponse.accessToken,
                    expirationDate: authResponse.tokenLifetime ?? 1000000000
                )
                credentialsProvider.setUserId(authResponse.userId)
                lock.unlock()
            }
            completion(.success(value))
        case .failure(let afError):
            if afError.responseCode == 401 {
                refreshAuthAndRetry(endpoint: endpoint, parameters: parameters, responseType: responseType, completion: completion)
            } else {
                completion(.failure(APIError.network(error: afError)))
            }
        }
    }
    
    private func withTryAuth(_ handler: @escaping (Result<AuthResponse, APIError>) -> ()) {
        lock.lock()
        credentialsProvider.setToken("", expirationDate: -1)
        
        let endpoint = AuthEndpoint.login
        let headers = endpoint.headers
        
        client.request(endpoint.urlString, method: endpoint.method, parameters: credentialsProvider.userCredentials, encoder: encoder, headers: headers)
            .validate()
            .responseDecodable(of: AuthResponse.self) { [weak self] response in
                switch response.result {
                case .success(let authResponse):
                    self?.credentialsProvider.setToken(
                        authResponse.accessToken,
                        expirationDate: authResponse.tokenLifetime ?? 1000000000
                    )
                    self?.credentialsProvider.setUserId(authResponse.userId)
                    handler(.success(authResponse))
                case .failure(let error):
                    self?.credentialsProvider.setCredentials(nil)
                    handler(.failure(APIError.network(error: error)))
                }
                self?.lock.unlock()
            }
    }
}

extension MIAPIClient: Downloadable {
    func downloadData(with endpoint: Endpoint, completion: @escaping (Result<Data, APIError>) -> ()) {
        guard case .get = endpoint.method else {
            completion(.failure(APIError.download(message: "Download should have GET method")))
            return
        }
        
        var headers = endpoint.headers
        lock.lock()
        if endpoint.authRequired, let token = credentialsProvider.token {
            headers.add(.authorization(bearerToken: token))
        }
        lock.unlock()
        
        client.request(endpoint.urlString, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.download(message: "No data received")))
                    }
                case .failure(let error):
                    completion(.failure(.network(error: error)))
                }
            }
    }
    
    func uploadPhoto(with endpoint: Endpoint, data: Data, itemId: Int64, completion: @escaping (Result<PhotoUploadResponse, APIError>) -> ()) {
        lock.lock()
        guard !endpoint.authRequired || credentialsProvider.token != nil else {
            lock.unlock()
            completion(.failure(.auth(message: "Перезайди в приложение")))
            return
        }
        
        var headers = HTTPHeaders()
        if endpoint.authRequired, let token = credentialsProvider.token {
            headers.add(.authorization(bearerToken: token))
        }
        
        let itemIdData = Data("\(itemId)".utf8)
        let totalLength = data.count + itemIdData.count
        headers.add(name: "Content-Length", value: String(totalLength))
        
        lock.unlock()
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
            multipartFormData.append(itemIdData, withName: "itemId")
        }, to: endpoint.urlString, method: .post, headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: PhotoUploadResponse.self) { response in
            switch response.result {
            case .success(let fileResponse):
                completion(.success(fileResponse))
            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Server Response: \(utf8Text)")
                } else {
                    print("No response data received.")
                }
                print("Error: \(error.localizedDescription)")
                completion(.failure(.dataCorrupted(message: error.errorDescription ?? "")))
            }
        }
    }
}

