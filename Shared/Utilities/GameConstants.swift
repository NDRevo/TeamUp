//
//  GameConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 8/8/22.
//

import Foundation
import SwiftUI

struct Rank: Identifiable, Hashable {
    var id: String {
        return self.rankName
    }

    let rankName: String
    let rankWeight: Int
}

struct Game: Identifiable, Hashable {
    var id: String {
        return self.name
    }

    let name: String
    let gameColor: Color
    private let ranks: [Rank]
    var gameVariants: [Game] = []

    init(name: String,gameColor: Color = .gray, ranks: [Rank], gameVariants: [Game] = []) {
        self.name = name
        self.gameColor = gameColor
        self.ranks = ranks
        self.gameVariants = gameVariants
    }

    func getRanksForGame(for variant: Game? = nil) -> [Rank]{
        if let variant = variant {
            return gameVariants.first(where: {$0.self == variant})!.ranks
        } else {
            return ranks
        }
    }
    
    func hasVariants() -> Bool {
        return !gameVariants.isEmpty
    }

    func hasRanks() -> Bool {
        return !ranks.isEmpty
    }
}

final class GameLibrary {
    static let data = GameLibrary()

    let games: [Game] = [
        Game(name: GameNames.all, ranks: []),
        Game(name: GameNames.none, ranks: []),
        Game(name: GameNames.amongus, gameColor: .amongus, ranks: []),
        Game(name: GameNames.apexlegends,
             gameColor: .apexlegend,
             ranks: [
                Rank(rankName: "Unranked",      rankWeight: 0),
                Rank(rankName: "Bronze",        rankWeight: 1),
                Rank(rankName: "Silver",        rankWeight: 2),
                Rank(rankName: "Gold",          rankWeight: 3),
                Rank(rankName: "Platinum",      rankWeight: 4),
                Rank(rankName: "Diamond",       rankWeight: 5),
                Rank(rankName: "Master",        rankWeight: 6),
                Rank(rankName: "Apex Predator", rankWeight: 7)
             ]
        ),

        Game(name: GameNames.counterstrike,
             gameColor: .counterstrike,
             ranks: [],
             gameVariants: [
                Game(name: "1.6", ranks: []),
                Game(name: "Source", ranks: []),
                Game(name: "Global Offensive", ranks: [
                    Rank(rankName: "Unranked",                      rankWeight: 0),
                    Rank(rankName: "Silver I",                      rankWeight: 1),
                    Rank(rankName: "Silver II",                     rankWeight: 1),
                    Rank(rankName: "Silver III",                    rankWeight: 1),
                    Rank(rankName: "Silver IIII",                   rankWeight: 2),
                    Rank(rankName: "Silver IV",                     rankWeight: 2),
                    Rank(rankName: "Silver Elite",                  rankWeight: 2),
                    Rank(rankName: "Silver Elite Master",           rankWeight: 3),
                    Rank(rankName: "Gold Nova I",                   rankWeight: 3),
                    Rank(rankName: "Gold Nova II",                  rankWeight: 3),
                    Rank(rankName: "Gold Nova III",                 rankWeight: 4),
                    Rank(rankName: "Gold Nova Master",              rankWeight: 4),
                    Rank(rankName: "Master Guardian I",             rankWeight: 5),
                    Rank(rankName: "Master Guardian II",            rankWeight: 5),
                    Rank(rankName: "Master Guardian Elite",         rankWeight: 6),
                    Rank(rankName: "Distinguished Master Guardian", rankWeight: 6),
                    Rank(rankName: "Legendary Eagle",               rankWeight: 7),
                    Rank(rankName: "Legendary Eagle Master",        rankWeight: 7),
                    Rank(rankName: "Supreme Master First Class",    rankWeight: 8),
                    Rank(rankName: "The Global Elite",              rankWeight: 9),
                 ])
             ]
        ),
        Game(name: GameNames.overwatch,
             gameColor: .overwatch,
             ranks: [
                Rank(rankName: "Unranked",      rankWeight: 0),
                Rank(rankName: "Bronze",        rankWeight: 1),
                Rank(rankName: "Silver",        rankWeight: 2),
                Rank(rankName: "Gold",          rankWeight: 3),
                Rank(rankName: "Platinum",      rankWeight: 4),
                Rank(rankName: "Diamond",       rankWeight: 5),
                Rank(rankName: "Master",        rankWeight: 6),
                Rank(rankName: "Grandmaster",   rankWeight: 7),
                Rank(rankName: "Top 500",       rankWeight: 8)
                
             ]
            ),
        Game(name: GameNames.valorant,
             gameColor: .valorant,
             ranks: [
                Rank(rankName: "Unranked",  rankWeight: 0),
                Rank(rankName: "Iron",      rankWeight: 1),
                Rank(rankName: "Bronze",    rankWeight: 2),
                Rank(rankName: "Silver",    rankWeight: 3),
                Rank(rankName: "Gold",      rankWeight: 4),
                Rank(rankName: "Platinum",  rankWeight: 5),
                Rank(rankName: "Diamond",   rankWeight: 6),
                Rank(rankName: "Ascendent", rankWeight: 7),
                Rank(rankName: "Immortal",  rankWeight: 8),
                Rank(rankName: "Radiant",   rankWeight: 9)
             ]
        )
    ]

    func getRanksForGame(for gameName: String, with gameVariant: String) -> [Rank]{
        if  !gameVariant.isEmpty {
            return games.first(where: {$0.name == gameName})!.gameVariants.first(where: {$0.name == gameVariant})!.getRanksForGame()
        }
        return games.first(where: {$0.name == gameName})!.getRanksForGame()
    }
}
