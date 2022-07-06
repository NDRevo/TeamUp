//
//  TURank.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit


struct TUPlayerGameProfile: Identifiable {

    static let kAssociatedToPlayer  = "associatedToPlayer"
    static let kGameName            = "gameName"
    static let kGameID              = "gameID"
    static let kGameRank            = "gameRank"
    static let kGameAliases         = "gameAlias" //MARK: Change to "gameAliases in CloudKit"

    let id: CKRecord.ID

    let gameName: String
    let gameID: String
    let gameRank: String
    let gameAliases: [String] //MARK: Make optional

    init(record: CKRecord){
        id  = record.recordID

        gameName    = record[TUPlayerGameProfile.kGameName]  as? String ?? "N/A"
        gameID      = record[TUPlayerGameProfile.kGameID]    as? String ?? "N/A"
        gameRank    = record[TUPlayerGameProfile.kGameRank]  as? String ?? "N/A"
        gameAliases   = record[TUPlayerGameProfile.kGameAliases] as? [String] ?? []
    }
}
