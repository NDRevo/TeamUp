//
//  TURank.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit


struct TUPlayerGameDetails: Identifiable {
    
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

        gameName    = record[TUPlayerGameDetails.kGameName]  as? String ?? "N/A"
        gameID      = record[TUPlayerGameDetails.kGameID]    as? String ?? "N/A"
        gameRank    = record[TUPlayerGameDetails.kGameRank]  as? String ?? "N/A"
    }
}
