//
//  TUPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import CloudKit
import SwiftUI

struct TUPlayer: Identifiable, Hashable {

    static let kUsername            = "username"
    static let kFirstName           = "firstName"
    static let kLastName            = "lastName"
    static let kProfileColor        = "profileColor"
    static let kInEvents            = "inEvents"
    static let kInSchool            = "inSchool"
    static let kOnTeams             = "onTeams"
    static let kIsClubLeader        = "isGameLeader"
    static let kIsVerfiedStudent    = "isVerifiedStudent"
    static let kClubLeaderClubName = "clubLeaderClubName"
    static let kClubLeaderRequestDescription = "clubLeaderRequestDescription"

    let record: CKRecord
    let id: CKRecord.ID

    let username: String
    let firstName: String
    let lastName: String
    let profileColor: Color
    let isClubLeader: Int
    let inEvents: [CKRecord.Reference]
    let inSchool: String
    let isVerifiedStudent: Int
    let clubLeaderClubName: String
    let clubLeaderRequestDescription: String

    init(record: CKRecord){
        self.record = record
        id  = record.recordID

        username            = record[TUPlayer.kUsername]        as? String ?? "N/A"
        firstName           = record[TUPlayer.kFirstName]       as? String ?? "N/A"
        lastName            = record[TUPlayer.kLastName]        as? String ?? "N/A"
        profileColor        = Color(hexString: record[TUPlayer.kProfileColor] as? String ?? "#42a7f5")
        isClubLeader        = record[TUPlayer.kIsClubLeader]    as? Int ?? 0
        inEvents            = record[TUPlayer.kInEvents]        as? [CKRecord.Reference] ?? []
        inSchool            = record[TUPlayer.kInSchool]        as? String ?? "N/A"
        isVerifiedStudent   = record[TUPlayer.kIsVerfiedStudent] as? Int ?? 0
        clubLeaderClubName  = record[TUPlayer.kClubLeaderClubName] as? String ?? ""
        clubLeaderRequestDescription = record[TUPlayer.kClubLeaderRequestDescription] as? String ?? ""
    }
}
