//
//  MatchDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/15/22.
//

import CloudKit

final class MatchDetailViewModel: ObservableObject {
    
    var match: TUMatch
    
    @Published var teams: [TUTeam]      = []
    @Published var isShowingAddPlayer   = false
    @Published var isShowingAddTeam     = false
    @Published var teamName             = ""
    
    init(match: TUMatch){
        self.match = match
    }
    
}
