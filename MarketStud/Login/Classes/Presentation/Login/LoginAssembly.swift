import UIKit

class LoginAssembly {
    private let service: ILoginService
    private let onLoginSuccess: () -> Void
    
    init(
        service: ILoginService,
        onLoginSuccess: @escaping () -> Void
    ) {
        self.service = service
        self.onLoginSuccess = onLoginSuccess
    }
    
    func assemble() -> LoginViewController {
        let viewController = LoginViewController()
        let registerAssembly = RegisterAssembly(service: service)
        let router = LoginRouter(
            viewController: viewController, 
            registerAssembly: registerAssembly,
            onLoginSuccess: onLoginSuccess
        )
        registerAssembly.router = router
        let presenter = LoginPresenter(view: viewController, service: service, router: router)
        viewController.presenter = presenter
        return viewController
    }
}
