//
//  AddPlayerGameProfileSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI

//MARK: AddPlayerGameProfileSheet
//INFO: Sheet to add game profile with Game+Variant, rank, and game ID
struct AddPlayerGameProfileSheet: View {

    @EnvironmentObject private var playerManager: PlayerManager

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section{
                Picker("Game", selection: $playerManager.selectedGame) {
                    ForEach(GameLibrary.data.games[3...], id: \.self){ game in
                        Text(game.name)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: playerManager.selectedGame) { newValue in
                    playerManager.resetGameProfileSelections(for: newValue)
                }

                if playerManager.selectedGame.hasVariants() {
                    Picker("Variant", selection: $playerManager.selectedGameVariant) {
                        ForEach(playerManager.selectedGame.gameVariants){game in
                            Text(game.name)
                                .tag(game as Game?)
                        }
                    }
                    .pickerStyle(.menu)

                } else if playerManager.selectedGame.hasRanks() {
                    Picker("Rank", selection: $playerManager.selectedGameRank) {
                        ForEach(playerManager.selectedGame.getRanksForGame()){ rank in
                            Text(rank.rankName)
                                .tag(rank as Rank?)
                        }
                    }
                }

                if let ranks = playerManager.selectedGameVariant {
                    if ranks.hasRanks() && !ranks.name.isEmpty {
                    Picker("Rank", selection: $playerManager.selectedGameRank) {
                            ForEach(ranks.getRanksForGame()){ rank in
                                Text(rank.rankName)
                                    .tag(rank as Rank?)
                            }
                        }
                    }
                }

                TextField("Game ID", text: $playerManager.gameID)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                    .textInputAutocapitalization(.never)
                    .onChange(of: playerManager.gameID) { _ in
                        playerManager.gameID = String(playerManager.gameID.prefix(25))
                    }
            }

            Section {
                Button {
                    Task {
                        playerManager.saveGameProfile()
                    }
                } label: {
                    Text("Add Game Profile")
                }
            }
        }
        .navigationTitle("Add Game Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") { dismiss() }
            }
        }
        .alert($playerManager.isShowingAddGameProfileAlert, alertInfo: playerManager.alertItem)
    }
}

struct AddPlayerGameProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerGameProfileSheet()
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
