//
//  FileManagerHelper.swift
//  VoiceyPush
//
//  Created by Michael Martin on 04/04/2022.
//

import Foundation

class FileManagerHelper {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let path = paths[0]
        
        return path
    }
    
    
    
}
