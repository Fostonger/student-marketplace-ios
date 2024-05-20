import UIKit

final class MainTabBarController: UITabBarController {
    
    private let mainPageAssembly: MainPageAssembly
    private let createItemAssembly: CreateItemAssembly
    private let profileAssembly: ProfileAssembly
    
    init(
        mainPageAssembly: MainPageAssembly,
        createItemAssembly: CreateItemAssembly,
        profileAssembly: ProfileAssembly
    ) {
        self.mainPageAssembly = mainPageAssembly
        self.createItemAssembly = createItemAssembly
        self.profileAssembly = profileAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let mainPageViewController = UINavigationController(
            rootViewController: mainPageAssembly.assemble()
        )
        mainPageViewController.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "house"), tag: 0)
        
        let addItemViewController = UINavigationController(
            rootViewController: createItemAssembly.assemble()
        )
        addItemViewController.tabBarItem = UITabBarItem(title: "Add Item", image: UIImage(systemName: "plus.circle"), tag: 1)
        
        let chatsViewController = UINavigationController(
            rootViewController: UIViewController()
        )
        chatsViewController.tabBarItem = UITabBarItem(title: "Chats", image: UIImage(systemName: "message"), tag: 2)
        
        let profileViewController = UINavigationController(
            rootViewController: profileAssembly.assemble()
        )
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 3)
        
        viewControllers = [mainPageViewController, addItemViewController, chatsViewController, profileViewController]
    }
}
