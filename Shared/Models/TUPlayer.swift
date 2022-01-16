//
//  TUPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import Foundation
import CloudKit

struct TUPlayer: Identifiable, Hashable {

    static let kFirstName     = "firstName"
    static let kLastName      = "lastName"
    static let kIsCheckedIn   = "isCheckedIn"
    static let kInEvents      = "inEvents"
    static let kOnTeams       = "onTeams"

    let id: CKRecord.ID

    let firstName: String
    let lastName: String

    init(record: CKRecord){
        id  = record.recordID

        firstName   = record[TUPlayer.kFirstName]     as? String ?? "N/A"
        lastName    = record[TUPlayer.kLastName]      as? String ?? "N/A"
    }
}
