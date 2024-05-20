import UIKit

final class RegisterAssembly {
    private let service: ILoginService
    weak var router: LoginRouter?
    
    init(
        service: ILoginService
    ) {
        self.service = service
    }
    
    func assemble() -> RegisterViewController {
        let presenter = RegisterPresenter(service: service, router: router)
        let viewController = RegisterViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
