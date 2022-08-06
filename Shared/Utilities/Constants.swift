//
//  Constants.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

enum Games: String, CaseIterable, Identifiable{
    var id: String {
        return self.rawValue
    }

    case all          = "All"
    case none         = "None"
    case apexlegends  = "Apex Legends"
    case overwatch    = "Overwatch"
    case valorant     = "VALORANT"

    func getRanksForGame() -> [String]{
        switch self {
        case .overwatch:    return ["Unranked", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster", "Top 500"]
        case .apexlegends:  return ["Unranked", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Apex Predator"]
        case .valorant:     return ["Unranked", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Immortal", "Radiant"]
        case .none:         return []
        case .all:          return []
        }
    }
}

enum RecordType{
    static let event             = "TUEvent"
    static let match             = "TUMatch"
    static let team              = "TUTeam"
    static let player            = "TUPlayer"
    static let playerGameProfiles = "TUPlayerGameDetails"
}
