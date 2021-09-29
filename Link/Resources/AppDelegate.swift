//
//  AppDelegate.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Firebase
import UIKit
import Appirater
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Appirater.appLaunched(true)
        Appirater.setAppId("3182731283")
        Appirater.setDebug(false)
        Appirater.setDaysUntilPrompt(3)

        GMSPlacesClient.provideAPIKey("AIzaSyC7B4xchyzZzmT0i6ymUE8AVBrgQ795vzk")
        FirebaseApp.configure()
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            fatalError()
//        }
//        let id = NotificationsManager.newIdentifier()
//        let dateString = DateFormatter.formatter.string(from: Date())
//        let model = LinkNotification(identifer: id,
//                                     notificationType: 1,
//                                     profilePictureUrl: "123",
//                                     postLinkIconImage: "123",
//                                     username: "Kubs",
//                                     dateString: dateString,
//                                     isFollowing: false,
//                                     isAccepted: false,
//                                     postId: "123",
//                                     postUrl: "123")
//            
//        NotificationsManager.shared.create(notification: model, for: username)

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

