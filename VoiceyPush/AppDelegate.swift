//
//  AppDelegate.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import UIKit
import CoreData
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, URLSessionDownloadDelegate, URLSessionDelegate {
    
    var notificationSoundPlayer: AVAudioPlayer?
    var notificationSoundData: Data?
    var notificationSoundName = "notificationSoundFile"
    var backgroundCompletionHandler: (() -> ())?
    var soundURL: URL?
    
    private lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MainSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.shouldUseExtendedBackgroundIdleMode = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let path = paths[0]
        
        return path
    }
    
    func downloadSoundFile() {
        guard let soundURL = soundURL else {
            return
        }
        
        let backgroundTask = backgroundURLSession.downloadTask(with: soundURL)
        backgroundTask.resume()
    }
    
    func writeFileToDocuments() {
        let uniqueFilePath = "\(notificationSoundName).mp3"
        
        let urlToWriteTo = getDocumentsDirectory().appendingPathComponent(uniqueFilePath)
        
        do {
            try notificationSoundData?.write(to: urlToWriteTo)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func writeSoundURLToDocuments(url: URL) {
        let uniqueFilePath = "\(notificationSoundName).mp3"
        
        let urlToWriteTo = getDocumentsDirectory().appendingPathComponent(uniqueFilePath)
        
        do {
            try FileManager.default.moveItem(at: url, to: urlToWriteTo)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchSoundFromDocuments() -> URL {
        let uniqueFilePath = "\(notificationSoundName).mp3"
        
        let soundURL = getDocumentsDirectory().appendingPathComponent(uniqueFilePath)
        
        return soundURL
    }
    
    func prepareSoundPlayer() {
        let soundURL = fetchSoundFromDocuments()
        
        do {
            try notificationSoundPlayer = AVAudioPlayer(contentsOf: soundURL)
            notificationSoundPlayer?.prepareToPlay()
        } catch {
            print("error:", error.localizedDescription)
        }
    }
    
    func playAudio(fileName: String) {
        prepareSoundPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("error:", error.localizedDescription)
        }
        
        notificationSoundPlayer?.play()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let backgroundCompletionHandler = self.backgroundCompletionHandler else {
                return
            }
            
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        writeSoundURLToDocuments(url: location)
        
        // send notification to self to trigger audio player??
    }
    
    func sendSoundPlayingNotificationToSelf() {
        
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "VoiceyPush")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

