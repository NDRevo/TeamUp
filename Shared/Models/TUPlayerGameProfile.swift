//
//  TURank.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit


struct TUPlayerGameProfile: Identifiable {

    static let kGameName            = "gameName"
    static let kGameID              = "gameID"
    static let kGameRank            = "gameRank"
    static let kAssociatedToPlayer  = "associatedToPlayer"

    let id: CKRecord.ID

    let gameName: String
    let gameID: String
    let gameRank: String

    init(record: CKRecord){
        id  = record.recordID

        gameName    = record[TUPlayerGameProfile.kGameName]  as? String ?? "N/A"
        gameID      = record[TUPlayerGameProfile.kGameID]    as? String ?? "N/A"
        gameRank    = record[TUPlayerGameProfile.kGameRank]  as? String ?? "N/A"
    }
}
