import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class FirebaseService: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let shared = FirebaseService()
    private let preferenceManager = PreferenceManager.shared
    
    private override init() {
        super.init()
    }
    
    func configure() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        if let token = fcmToken {
            preferenceManager.setStringValue(token, forKey: "fcm_token")
            updateAuthToken(token)
        }
    }
    
    // MARK: - Token Update
    private func updateAuthToken(_ deviceToken: String) {
        guard let customerId = preferenceManager.getStringValue("customer_id"),
              !customerId.isEmpty,
              !deviceToken.isEmpty else {
            return
        }
        
        let parameters: [String: Any] = [
            "customer_id": customerId,
            "authToken": deviceToken
        ]
        
        // Get the server token for authentication
        guard let serverToken = AccessToken.getCustomerAccessToken() else {
            print("Failed to get server token")
            return
        }
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "update_firebase_customer_token",
            parameters: parameters,
            authToken: serverToken
        ) { result in
            switch result {
            case .success(let response):
                print("Token update response: \(response)")
            case .failure(let error):
                print("Token update error: \(error)")
            }
        }
    }
    
    // MARK: - Notification Handling
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let intent = userInfo["intent"] as? String {
            handleNotificationIntent(intent, data: userInfo)
        }
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let intent = userInfo["intent"] as? String {
            handleNotificationIntent(intent, data: userInfo)
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Intent Handling
    private func handleNotificationIntent(_ intent: String, data: [AnyHashable: Any]) {
        switch intent {
        case "customer_home":
            handleCustomerHome()
        case "live_tracking":
            handleLiveTracking(data)
        case "end_live_tracking":
            handleEndLiveTracking()
        // Add other cases as needed
        default:
            showRegularNotification(data)
        }
    }
    
    private func handleCustomerHome() {
        preferenceManager.setBooleanValue(false, forKey: "live_ride")
        preferenceManager.setStringValue("", forKey: "current_booking_id")
        // Navigate to home
    }
    
    private func handleLiveTracking(_ data: [AnyHashable: Any]) {
        if let bookingId = data["booking_id"] as? String {
            preferenceManager.setStringValue(bookingId, forKey: "current_booking_id")
            preferenceManager.setBooleanValue(true, forKey: "live_ride")
            // Navigate to ongoing booking details
        }
    }
    
    private func handleEndLiveTracking() {
        preferenceManager.setBooleanValue(false, forKey: "live_ride")
        preferenceManager.setStringValue("", forKey: "current_booking_id")
        // Show toast and navigate to home
    }
    
    private func showRegularNotification(_ data: [AnyHashable: Any]) {
        let content = UNMutableNotificationContent()
        content.title = data["title"] as? String ?? ""
        content.body = data["body"] as? String ?? ""
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 
