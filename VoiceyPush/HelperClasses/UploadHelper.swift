//
//  MainHelperFunctions.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import Foundation
import Firebase

class UploadHelper {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    var uploadDelegate: UploadDelegate?
    
    var uploadedVoiceyDownloadURLString: String?
    
    func uploadVoiceyToFirebase(voiceyName: String?, voiceyURL: URL) {
        guard let voiceyName = voiceyName else {
            return
        }
        
        let voiceyUID = UUID().uuidString
        
        let voiceyStorageRef = storageRef.child("\(voiceyUID).mp3")
        
        voiceyStorageRef.putFile(from: voiceyURL, metadata: nil) { metadata, error in
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
