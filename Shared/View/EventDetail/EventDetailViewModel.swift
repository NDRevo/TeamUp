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
    
    //Players that join/added to the event from the players list
    @Published var players: [String] = ["John", "Mick", "David"]
    
    @Published var matches: [TUMatch] = [TUMatch(date: Date(), name: "Immortal"),TUMatch(date: Date(), name: "Diamond"),TUMatch(date: Date(), name: "Randoms")]
}
