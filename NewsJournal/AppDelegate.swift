//
//  AppDelegate.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

import RealmSwift
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //Notification User Authorization
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        //FCM wrapping
        Messaging.messaging().delegate = self
        
        
        //schema update
        let config = Realm.Configuration(schemaVersion: 3) { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 0 {

            }
            
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        
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

//MARK: - Extension for UserNotificationDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        print("APNS token: ", token)
    }
    
}


//MARK: - Extension for MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    
}
