//
//  MainHelperFunctions.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import Foundation
import Firebase

class DatabaseFunctions {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    var uploadDelegate: UploadDelegate?
    
    var uploadedVoiceyDownloadURLString: String?
    
    func uploadVoiceyToFirebase(voiceyName: String?, voiceyData: Data?) {
        guard let voiceyName = voiceyName else {
            return
        }
        
        guard let voiceyData = voiceyData else {
            return
        }
        
        let voiceyUID = UUID().uuidString
        
        let voiceyStorageRef = storageRef.child("\(voiceyUID).mp3")
        
        voiceyStorageRef.putData(voiceyData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                
                self.uploadDelegate?.didFinishUploadTask(success: false)
                
                return
            }
            
            voiceyStorageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                let urlString = url?.absoluteString
                
                self.uploadedVoiceyDownloadURLString = urlString
                
                self.uploadDelegate?.didFinishUploadTask(success: true)
            }
        }
        
    }
    
}
