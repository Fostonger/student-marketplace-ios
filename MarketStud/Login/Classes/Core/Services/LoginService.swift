//
//  RegisterService.swift
//  StartIt
//
//  Created by Булат Мусин on 18.04.2024.
//

import Foundation

protocol ILoginService {
    func register(model: RegisterModel, completion: @escaping (Result<Void, APIError>) -> Void)
    func login(model: LoginModel, completion: @escaping (Result<Void, APIError>) -> Void)
}

final class LoginService: ILoginService {
    
    // Dependencies
    private let apiClient: APIClient
    
    
    // MARK: - Initialization
    
    init(
        client: APIClient
    ) {
        self.apiClient = client
    }
    
    func register(model: RegisterModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = AuthEndpoint.register
        
        apiClient.fetch(with: endpoint, parameters: model, responseType: AuthResponse.self) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(model: LoginModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = AuthEndpoint.login
        
        apiClient.fetch(with: endpoint, parameters: model, responseType: AuthResponse.self) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

