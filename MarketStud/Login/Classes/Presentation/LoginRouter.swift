//
//  LoginRouter.swift
//  StartIt
//
//  Created by Булат Мусин on 18.04.2024.
//

import UIKit

final class LoginRouter {
    private weak var viewController: UIViewController?
    private let onLoginSuccess: () -> Void
    private let registerAssembly: RegisterAssembly
    
    init(
        viewController: UIViewController,
        registerAssembly: RegisterAssembly,
        onLoginSuccess: @escaping () -> Void
    ) {
        self.viewController = viewController
        self.registerAssembly = registerAssembly
        self.onLoginSuccess = onLoginSuccess
    }
    
    func navigateToHome() {
        onLoginSuccess()
    }
    
    func navigateToRegister() {
        let registerViewController = registerAssembly.assemble()
        
        viewController?.navigationController?.pushViewController(registerViewController, animated: true)
    }
}

