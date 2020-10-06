//
//  AppDelegate.swift
//  AppStore
//
//  Created by Seoyoung on 2020/09/16.
//  Copyright © 2020 Seoyoung. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let search = AppContainer.shared.resolve(MainViewController.self)!
        search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let searchNaviVC = UINavigationController(rootViewController: search)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [searchNaviVC]

        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()

        return true
    }
}
