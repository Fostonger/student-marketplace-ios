//
//  LoginViewModel.swift
//  StartIt
//
//  Created by Булат Мусин on 10.01.2024.
//

import Foundation

final class LoginPresenter {
    private weak var view: LoginView?
    private let service: ILoginService
    private let router: LoginRouter
    
    init(view: LoginView, service: ILoginService, router: LoginRouter) {
        self.view = view
        self.service = service
        self.router = router
    }
    
    func loginUser(with model: LoginModel) {
        view?.showLoading()
        service.login(model: model) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                switch result {
                case .success:
                    self?.view?.showSuccess()
                    self?.router.navigateToHome()
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    func navigateToRegister() {
        router.navigateToRegister()
    }
}

