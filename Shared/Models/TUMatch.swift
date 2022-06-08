//
//  TUMatch.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import CloudKit

struct TUMatch: Identifiable, Hashable {
    
    static let kMatchName = "matchName"
    static let kStartTime = "matchStartTime"
    static let kAssociatedToEvent = "associatedToEvent"

    let id: CKRecord.ID

    let matchName: String
    let matchStartTime: Date

    init(record: CKRecord){
        id = record.recordID
        
        matchName      = record[TUMatch.kMatchName] as? String ?? "N/A"
        matchStartTime = record[TUMatch.kStartTime] as? Date ?? Date()
    }
}
