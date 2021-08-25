//
//  TabBarViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

/// Primary tab controller for core app UI
final class TabBarViewController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllers()

    }

    /// Sets up tab bar controllers
    private func setUpControllers() {
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }

        let currentUser = User(
            username: username,
            email: email
        )

        // Define VCs
//        let home = HomeViewController()
        let explore = ExploreViewController()
        let notifications = NotificationsViewController()
        let maps = MapsViewController()
        let feed = LinkNotificationViewController()
//        let linkPage = LinkNotificationViewController()

//        let nav1 = UINavigationController(rootViewController: linkPage)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: notifications)
        let nav4 = UINavigationController(rootViewController: maps)
        let nav5 = UINavigationController(rootViewController: feed)

//        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        nav4.navigationBar.tintColor = .label
        nav5.navigationBar.tintColor = .label

        if #available(iOS 14.0, *) {
//            linkPage.navigationItem.backButtonDisplayMode = .minimal
            explore.navigationItem.backButtonDisplayMode = .minimal
            notifications.navigationItem.backButtonDisplayMode = .minimal
            maps.navigationItem.backButtonDisplayMode = .minimal
            feed.navigationItem.backButtonDisplayMode = .minimal
        } else {
//            nav1.navigationItem.backButtonTitle = ""
            nav2.navigationItem.backButtonTitle = ""
            nav3.navigationItem.backButtonTitle = ""
            nav4.navigationItem.backButtonTitle = ""
            nav5.navigationItem.backButtonTitle = ""
        }

        // Define tab items
//        nav1.tabBarItem = UITabBarItem(title: "Link", image: UIImage(systemName: "link"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "suit.heart"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "location.fill"), tag: 1)
        nav5.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "link"), tag: 1)

        // Set controllers
        self.setViewControllers(
            [nav4, nav2, nav3, nav5],
            animated: false
        )
    }
}

