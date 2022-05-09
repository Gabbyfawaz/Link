//
//  AppDelegate.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Firebase
import UIKit
import Appirater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        Appirater.appLaunched(true)
        Appirater.setAppId("3182731283")
        Appirater.setDebug(false)
        Appirater.setDaysUntilPrompt(3)

        
        // have to put API Key in a safe file 
//        GMSPlacesClient.provideAPIKey("AIzaSyC7B4xchyzZzmT0i6ymUE8AVBrgQ795vzk")
        FirebaseApp.configure()


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

