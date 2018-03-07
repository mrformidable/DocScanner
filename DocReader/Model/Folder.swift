//
//  Folder.swift
//  DocReader
//
//  Created by Michael A on 2018-02-20.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation


struct Folder: Codable {
    
    var name: String
    var date: Date
    var isPasswordProtected: Bool
    var uniqueIdentifier: UUID
    
    func saveNewFolder() {
        DataManager.save(self, with: uniqueIdentifier.uuidString)
    }
    
    func deleteFolder() {
        DataManager.delete(uniqueIdentifier.uuidString)
    }
}




