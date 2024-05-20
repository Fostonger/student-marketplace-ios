import UIKit

class ProfileAssembly {
    private let profileService: ProfileService
    private let logoutHandler: () -> ()
    private let createItemAssembly: ItemDetailsAssemblyProtocol

    init(
        profileService: ProfileService,
        logoutHandler: @escaping () -> (),
        createItemAssembly: ItemDetailsAssemblyProtocol
    ) {
        self.profileService = profileService
        self.logoutHandler = logoutHandler
        self.createItemAssembly = createItemAssembly
    }

    func assemble() -> ProfileViewController {
        let viewController = ProfileViewController()
        let router = ProfileRouter(
            viewController: viewController,
            createItemAssembly: createItemAssembly,
            logoutHandler: logoutHandler
        )
        let presenter = ProfilePresenter(view: viewController, service: profileService, router: router)
        viewController.presenter = presenter
        return viewController
    }
}

