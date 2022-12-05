//
//  GameConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 8/8/22.
//

import Foundation
import SwiftUI

enum GameNames {
    static let empty            = ""
    static let none             = "None"
    static let all              = "All"
    static let amongus          = "Among Us"
    static let apexlegends      = "Apex Legends"
    static let counterstrike    = "Counter Strike: "
    static let hearthstone      = "Hearthstone"
    static let leagueoflegends  = "League of Legends"
    static let overwatch        = "Overwatch"
    static let other            = "Other"
    static let valorant         = "VALORANT"
}

struct Rank: Identifiable, Hashable {
    var id: String {
        return self.rankName
    }

    let rankName: String
    let rankWeight: Int
}

struct Game: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String {
        return self.name
    }

    let name: String
    let gameColor: Color
    private let ranks: [Rank]
    var gameVariants: [Game] = []
    let image: Image?

    init(name: String,gameColor: Color = .gray, ranks: [Rank], gameVariants: [Game] = [], image: Image? = nil) {
        self.name = name
        self.gameColor = gameColor
        self.ranks = ranks
        self.gameVariants = gameVariants
        self.image = image
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

//MARK: GameLibrary
//INFO: Singleton containing list of supported games
final class GameLibrary {
    static let data = GameLibrary()

    let games: [Game] = [
        Game(name: GameNames.all, ranks: [],image: Image(systemName: "rectangle.stack.fill")),
        Game(name: GameNames.none, ranks: [],image: Image(systemName: "square.grid.2x2.fill")),
        Game(name: GameNames.other, ranks: [],image: Image(systemName: "questionmark.app.fill")),
        Game(name: GameNames.amongus, gameColor: .amongus, ranks: [], image: Image(GameNames.amongus)),
        //MARK: Apex Legends
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
             ],
             image: Image(GameNames.apexlegends)
        ),
        //MARK: Counter Strike
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
             ],
             image: Image(GameNames.counterstrike)
        ),
        //MARK: Hearthstone
        Game(name: GameNames.hearthstone, gameColor: .hearthstone, ranks: [], image: Image(GameNames.hearthstone)),
        //MARK: League of Legends
        Game(name: GameNames.leagueoflegends, gameColor: .leagueoflegends, ranks: [],image: Image(GameNames.leagueoflegends)),
        //MARK: Overwatch
        Game(name: GameNames.overwatch,
             gameColor: .overwatch,
             ranks: [
                Rank(rankName: "Unranked",
                     rankWeight: 0),
                Rank(rankName: "Bronze",        rankWeight: 1),
                Rank(rankName: "Silver",        rankWeight: 2),
                Rank(rankName: "Gold",          rankWeight: 3),
                Rank(rankName: "Platinum",      rankWeight: 4),
                Rank(rankName: "Diamond",       rankWeight: 5),
                Rank(rankName: "Master",        rankWeight: 6),
                Rank(rankName: "Grandmaster",   rankWeight: 7),
                Rank(rankName: "Top 500",       rankWeight: 8)
                
             ],
             image: Image(GameNames.overwatch)
            ),
        //MARK: VALORANT
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
             ],
             image: Image(GameNames.valorant)
        )
    ]

    func getRanksForGame(for gameName: String, with gameVariant: String) -> [Rank]{
        if  !gameVariant.isEmpty {
            return games.first(where: {$0.name == gameName})!.gameVariants.first(where: {$0.name == gameVariant})!.getRanksForGame()
        }
        return games.first(where: {$0.name == gameName})!.getRanksForGame()
    }

    func getGameByName(gameName: String) -> Game {
        return games.first(where: {$0.name == gameName}) ?? Game(name: gameName, ranks: [])
    }

    func getGameVariantByGameName(gameName: String, gameVariantName: String) -> Game {
        return games.first(where: {$0.name == gameName})?.gameVariants.first(where: {$0.name == gameVariantName}) ?? Game(name: gameVariantName, ranks: [])
    }
}
