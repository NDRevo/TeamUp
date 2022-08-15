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

    @EnvironmentObject private var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section{
                Picker("Game", selection: $viewModel.selectedGame) {
                    ForEach(GameLibrary.data.games[2...]){ game in
                        Text(game.name)
                            .tag(game.self)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.selectedGame) { newValue in
                    viewModel.resetRankList(for: newValue)
                }

                if viewModel.selectedGame.hasVariants() {
                    Picker("Variant", selection: $viewModel.selectedGameVariant) {
                        ForEach(viewModel.selectedGame.gameVariants){game in
                            Text(game.name)
                                .tag(game.self)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                } else if viewModel.selectedGame.hasRanks() {
                    Picker("Rank", selection: $viewModel.selectedGameRank) {
                        ForEach(viewModel.selectedGame.getRanksForGame()){ rank in
                            Text(rank.rankName)
                                .tag(rank.self)
                        }
                    }
                }
                
                if viewModel.selectedGameVariant.hasRanks() && !viewModel.selectedGameVariant.name.isEmpty {
                    Picker("Rank", selection: $viewModel.selectedGameRank) {
                        ForEach(viewModel.selectedGameVariant.getRanksForGame()){ rank in
                            Text(rank.rankName)
                                .tag(rank.self)
                        }
                    }
                }
    
                TextField("Game ID", text: $viewModel.gameID)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                    .textInputAutocapitalization(.never)
            }

            Section {
                Button {
                    Task {
                        dismiss()
                        try await Task.sleep(nanoseconds: 50_000_000)
                        viewModel.saveGameProfile(to: eventsManager)
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
    }
}

struct AddPlayerGameProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerGameProfileSheet(viewModel: PlayerProfileViewModel())
            .environmentObject(EventsManager())
    }
}
