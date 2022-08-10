//
//  GameConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 8/8/22.
//

import Foundation

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
    private let ranks: [Rank]
    let gameVariants: [Game]?

    init(name: String, ranks: [Rank], gameVariants: [Game]? = nil) {
        self.name = name
        self.ranks = ranks
        self.gameVariants = gameVariants
    }

    func getRanksForGame() -> [Rank]{
        return ranks
    }
}

final class GameLibrary {
    static let data = GameLibrary()

    let games: [Game] = [
        Game(name: GameNames.all, ranks: []),
        Game(name: GameNames.none, ranks: []),
        Game(name: GameNames.amongus,ranks: []),
        Game(name: GameNames.apexlegends,
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
        Game(name: GameNames.overwatch,
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

    func getRanksForGame(for gameName: String) -> [Rank]{
        return games.first(where: {$0.name == gameName})!.getRanksForGame()
    }
}
