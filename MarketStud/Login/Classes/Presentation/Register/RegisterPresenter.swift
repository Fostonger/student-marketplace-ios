import Foundation

final class RegisterPresenter {
    weak var view: RegisterView?
    private let service: ILoginService
    private weak var router: LoginRouter?
    
    init(
        service: ILoginService,
        router: LoginRouter?
    ) {
        self.service = service
        self.router = router
    }
    
    func registerUser(with model: RegisterModel) {
        view?.showLoading()
        service.register(model: model) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                switch result {
                case .success:
                    self?.router?.navigateToHome()
                case .failure(let error):
                    self?.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}
