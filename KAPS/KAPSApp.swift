//
//  KAPSApp.swift
//  KAPS
//
//  Created by Shaheed on 23/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

@main
struct KAPSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light) // Force light mode
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set the launch screen background color to match your splash screen
        if let window = UIApplication.shared.windows.first {
            window.backgroundColor = UIColor(Colors.primary)
        }
        
        // Initialize Firebase
        FirebaseService.shared.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
