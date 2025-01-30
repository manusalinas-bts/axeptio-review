//
//  AppDelegate.swift
//  AppXeptio
//
//  Created by Manuel Salinas on 1/27/25.
//

import UIKit
import AxeptioSDK
import GoogleMobileAds
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // * * * Axeptio setup
        // sample init
//        Axeptio.shared.initialize(targetService: .brands, clientId: "679901100d9a47f71b01afdf", cookiesVersion: "appxeptio-google-manu"//"appxeptio-en-MX-LAT")

        // or with a token set from an other device (you are in charge to store and pass the token along between devices)
        //Axeptio.shared.initialize(targetService: targetService, clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>", token: "<Token>")

        // * * Google Ads
        GADMobileAds.sharedInstance().start()

        // * * * Firebase setup
        FirebaseApp.configure()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

