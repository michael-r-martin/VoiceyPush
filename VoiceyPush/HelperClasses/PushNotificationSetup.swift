//
//  PushNotificationSetup.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import Foundation
import Firebase
import UserNotifications

class PushNotificationSetup: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    let userID: String?
    
    init(userID: String?) {
        self.userID = userID
    }
    
    func registerForPushNotifications() {
        
        if #available(iOS 10.0, *) {
            
        UNUserNotificationCenter.current().delegate = self
            
        Messaging.messaging().delegate = self
            
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in
                
                let notificationHelper = NotificationHelper()
                notificationHelper.checkNotificationPermission()
                
            })
            
        } else {
            let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        
        UIApplication.shared.registerForRemoteNotifications()
        
        
    }
    
    func updateFirestorePushTokenIfNeeded() {
        
        guard let token = Messaging.messaging().fcmToken else {return}
        print("token: \(token)")
        
        guard let uid = userID else {return}
        
        let usersRef = Firestore.firestore().collection("users").document(uid)
        
        let data = ["fcmToken": token]
        
        usersRef.setData(data, merge: true)

    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
    
}
