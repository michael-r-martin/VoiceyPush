//
//  HomeViewController.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var voiceyLabel: UILabel!
    @IBOutlet weak var recordButtonView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - Variables
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    // MARK: - State Variables
    var isCurrentlyRecording: Bool = false
    
    // MARK: - Classes
    let uploadHelper = UploadHelper()
    let fileManagerHelper = FileManagerHelper()
    let notificationHelper = NotificationHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView()
    }
    
    // MARK: - IBActions
    @IBAction func recordButtonPressed(_ sender: Any) {
        if !isCurrentlyRecording {
            startRecordingSession()
        } else {
            finishRecording(success: true)
        }
    }
    
    
    func styleView() {
        recordButtonView.layer.cornerRadius = recordButtonView.bounds.height/2
        recordButtonView.layer.cornerCurve = .continuous
    }
    
    func startRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        recordButton.setTitle("done 💁🎤", for: .normal)
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            recordingSession?.requestRecordPermission({ allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        print("not allowed to record audio")
                    }
                }
            })
        } catch {
            
        }
        
    }
    
    func startRecording() {
        let audioFilePath = fileManagerHelper.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        let audioFilePath = fileManagerHelper.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            uploadHelper.uploadVoiceyToFirebase(voiceyName: nil, voiceyURL: audioFilePath)
        } else {
            
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

}

extension HomeViewController: UploadDelegate {
    
    func didFinishUploadTask(success: Bool) {
        if success {
            notificationHelper.sendPushNotificationToFriend(notifTitle: "test 1", notifBody: "hey man.", senderName: "mikez", soundDownloadURLString: uploadHelper.uploadedVoiceyDownloadURLString, receiverFCMToken: "")
            #warning("placeholders above")
        }
    }
    
}
