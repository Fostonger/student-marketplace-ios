//
//  SceneDelegate.swift
//  MarketStud
//
//  Created by Булат Мусин on 18.05.2024.
//

import UIKit
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var storage: IStorage!
    private var apiClient: APIClient!
    private var appState: UserDefaultAppState!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        appState = UserDefaultAppState(with: UserDefaults.standard)
        apiClient = MIAPIClient(with: AF, credentialsProvider: appState)
        storage = Storage()
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        
        if appState.token != nil {
            navigateToMainPage()
        } else {
            navigateToLoginPage()
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func navigateToLoginPage() {
        let service = LoginService(client: apiClient)
        let loginAssembly = LoginAssembly(
            service: service
        ) { [weak self] in
            self?.navigateToMainPage()
        }
        let loginViewController = loginAssembly.assemble()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = navigationController
    }
    
    private func navigateToMainPage() {
        var chatDeeplink: ChatDeeplink? = nil
        
        let chatListAssembly = ChatListAssembly(apiClient: apiClient, userId: appState.userId!) { newChatDeeplink in
            chatDeeplink = newChatDeeplink
        }
        
        let mainPageService = MainPageService(client: apiClient, storage: storage)
        let mainPageAssembly = MainPageAssembly(service: mainPageService, userId: appState.userId!, chatDeeplink: chatDeeplink)
        
        let createItemService = CreateItemService(client: apiClient, isNew: true, userId: appState.userId!)
        let createItemAssembly = CreateItemAssembly(service: createItemService)
        
        let profileService = ProfileService(client: apiClient, for: appState.userId!)
        let logoutHandler = { [weak self] in
            self?.appState.setCredentials(nil)
            self?.appState.setToken("", expirationDate: -1)
            self?.navigateToLoginPage()
        }
        let createItemServiceForProfile = CreateItemService(client: apiClient, isNew: false, userId: appState.userId!)
        let createItemAssemblyForProfile = CreateItemAssembly(service: createItemServiceForProfile)
        let profileAssembly = ProfileAssembly(
            profileService: profileService,
            logoutHandler: logoutHandler,
            createItemAssembly: createItemAssemblyForProfile
        )
        
        let mainTabBarController = MainTabBarController(
            mainPageAssembly: mainPageAssembly,
            createItemAssembly: createItemAssembly,
            profileAssembly: profileAssembly,
            chatListAssembly: chatListAssembly
        )
        window?.rootViewController = mainTabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

