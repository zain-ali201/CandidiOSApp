//
//  AppDelegate.swift
//  Candid
//
//  Created by khrmac on 2021/3/22.
//

import UIKit
import IQKeyboardManagerSwift
import Toast_Swift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in
            
        }
        logFonts()
        application.registerForRemoteNotifications()
//        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func logFonts(){
        for family in UIFont.familyNames {

            let sName: String = family as String
            print("family: \(sName)")
                    
            for name in UIFont.fontNames(forFamilyName: sName) {
                print("name: \(name as String)")
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//        application.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: NSNotification.Name("active"), object: nil)
    }

}

extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        token = fcmToken
        print("firebase Token: \(token ?? "")")
        if currentUser != nil{
            APIManager.shared.updateToken(id: currentUser!.uid, token: token!) { (success, message) in
                
            }
        }else if let uid = UserDefaults.standard.value(forKey: "userID") as? Int{
            APIManager.shared.updateToken(id: uid, token: token!) { (success, message) in
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
}
///com.shannon.Candid
//https://medium.com/swlh/updating-users-to-the-latest-app-release-on-ios-ed96e4c76705
