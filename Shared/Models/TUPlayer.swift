//
//  TUPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import CloudKit

struct TUPlayer: Identifiable, Hashable {

    static let kUsername        = "userName"
    static let kFirstName       = "firstName"
    static let kLastName        = "lastName"
    static let kInEvents        = "inEvents"
    static let kOnTeams         = "onTeams"
    static let kIsGameLeader    = "isGameLeader"

    let id: CKRecord.ID

    let username: String
    let firstName: String
    let lastName: String
    let isGameLeader: Int

    init(record: CKRecord){
        id  = record.recordID

        username        = record[TUPlayer.kUsername]      as? String ?? "N/A"
        firstName       = record[TUPlayer.kFirstName]     as? String ?? "N/A"
        lastName        = record[TUPlayer.kLastName]      as? String ?? "N/A"
        isGameLeader    = record[TUPlayer.kIsGameLeader]  as? Int    ?? 0
    }
}
