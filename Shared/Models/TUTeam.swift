//
//  TUTeam.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import Foundation
import CloudKit

struct TUTeam: Identifiable {
    
    static let kAssociatedToMatch = "associatedToMatch"
    static let kTeamName          = "teamName"
    static let kCreationDate  = "creationDate"
    
    let id: CKRecord.ID
    let teamName: String
    
    init(record: CKRecord){
        id       = record.recordID
        teamName = record[TUTeam.kTeamName] as? String ?? "N/A"
    }
}
