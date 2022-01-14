//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import Foundation


final class EventDetailViewModel: ObservableObject {
    @Published var isShowingAddMatch = false
    @Published var isShowingAddPlayer = false
    @Published var isShowingAddAdmin = false
    
    @Published var players: [String] = ["John", "Mick", "David"]
    @Published var matches: [TUMatch] = [TUMatch(date: Date(), name: "Immortal"),TUMatch(date: Date(), name: "Diamond"),TUMatch(date: Date(), name: "Randoms")]
    
    func getRanksForGame(game: Games) -> [String]{
        switch game {
            
        case .overwatch:
            return ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster", "Top 500"]
        case .apex:
            return ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Apex Predator"]
        case .VALORANT:
            return ["Iron", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Immortal", "Radiant"]
        }
    }
}
