//
//  EventsManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import Foundation
import CloudKit

final class EventsManager: ObservableObject {
    @Published var events: [TUEvent]    = []
    @Published var players: [TUPlayer]  = []
    @Published var playerDetails: [CKRecord.ID:[TUPlayerGameDetails]] = [:]
    @Published var playerCountPerEvent: [CKRecord.ID:Int] = [:]

    func getRanksForGame(game: Games) -> [String]{
        switch game {
            case .overwatch:
                return ["None", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster", "Top 500"]
            case .apex:
                return ["None", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Apex Predator"]
            case .valorant:
                return ["None", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Immortal", "Radiant"]
            case .none:
                return []
        }
    }
}
