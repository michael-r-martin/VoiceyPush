//
//  NotificationHelper.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import Foundation
import UserNotifications
import NotificationCenter
import Firebase

class NotificationHelper {
    
    // MARK: - Let Constants
    //let dateHelper = CalendarDateHelper()
    
    func createNotificationContent(title: String, body: String, badge: Int, sound: UNNotificationSound) -> UNMutableNotificationContent {
        
        // Create Notification Content Instance
        let notificationContent = UNMutableNotificationContent()
        
        let badgeNumber = NSNumber(value: badge)
        
        let notifSound = UNNotificationSound.default
        
        // Establishing Notification Content
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = badgeNumber
        notificationContent.sound = notifSound
        
        return notificationContent
    }
    
    func scheduleLocalNotification(notificationContent: UNMutableNotificationContent, notificationDate: DateComponents, repeats: Bool, identifier: String) {
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if let error = error {
                print("Notification Error: ", error)
            }
            
        }
        
    }
    
    func sendPushNotificationToFriend(notifTitle: String?, notifBody: String?, senderName: String?, soundDownloadURLString: String?, receiverFCMToken: String?) {
        guard let notifTitle = notifTitle else {
            print(#function, #line)
            return
        }
        
        guard let notifBody = notifBody else {
            print(#function, #line)
            return
        }
        
        guard let senderName = senderName else {
            print(#function, #line)
            return
        }
        
        let receiverFCMToken = receiverFCMToken ?? ""
        
        let pushNotificationData: [String: Any] = [
        
            "to": receiverFCMToken,
            "notification": [
                "title": notifTitle,
                "body": notifBody,
                "sound": "default",
                "content-available": 1,
                "badge": 1
            ],
            "data": [
                "notificationType": "soundDownloading",
                "senderName": senderName,
                "soundDownloadURLString": soundDownloadURLString
            ]
        
        ]
        
        performPushNotifAPIRequest(pushNotificationData: pushNotificationData)
    }
    
    func sendSoundPlayingNotificationToSelf(notifTitle: String?, notifBody: String?, senderName: String?, soundDownloadURLString: String?) {
        guard let notifTitle = notifTitle else {
            print(#function, #line)
            return
        }
        
        guard let notifBody = notifBody else {
            print(#function, #line)
            return
        }
        
        guard let senderName = senderName else {
            print(#function, #line)
            return
        }
        
        let receiverFCMToken = Messaging.messaging().fcmToken ?? ""
        
        let pushNotificationData: [String: Any] = [
        
            "to": receiverFCMToken,
            "notification": [
                "title": notifTitle,
                "body": notifBody,
                "sound": "default",
                "content-available": 1,
                "badge": 1
            ],
            "data": [
                "notificationType": "soundPlaying",
                "senderName": senderName,
                "soundDownloadURLString": soundDownloadURLString
            ]
        
        ]
        
        performPushNotifAPIRequest(pushNotificationData: pushNotificationData)
    }
    
    func performPushNotifAPIRequest(pushNotificationData: [String: Any]) {
        let authKey = "key=AAAA02J1G5I:APA91bHKtpVo60WQxQJp_25cabmYnu1eAwfoTA1_XJ4LjtpACYVXEVnDMOTTEZaL3pjF5K-kVM_jZqQ6DvKpmd5S4-wbXHe8YN-ZIojteXA-BKsc4Ibl0mLbUA7iQbIuQLznpu41PM7F"
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: pushNotificationData, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
       
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let jsonData = data else {return}
            
          do {
                let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            print(jsonDataDict as Any)
          } catch {
            print(error.localizedDescription)
          }
            
        }
        task.resume()
        
    }
    
    func checkNotificationPermission() {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                UserDefaults.standard.setValue(true, forKey: "NotificationsAuthorized")
                UserDefaults.standard.setValue(true, forKey: "NotificationsTurnedOn")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                UserDefaults.standard.setValue(false, forKey: "NotificationsAuthorized")
                UserDefaults.standard.setValue(false, forKey: "NotificationsTurnedOn")
            default:
                break
            }
        })
    }
    
}
