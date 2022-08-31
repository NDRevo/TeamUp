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
                    ForEach(GameLibrary.data.games[1...], id: \.self){ game in
                        Text(game.name)
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
                                .tag(game as Game?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                } else if viewModel.selectedGame.hasRanks() {
                    Picker("Rank", selection: $viewModel.selectedGameRank) {
                        ForEach(viewModel.selectedGame.getRanksForGame()){ rank in
                            Text(rank.rankName)
                                .tag(rank as Rank?)
                        }
                    }
                }
                
                if let ranks = viewModel.selectedGameVariant {
                    if ranks.hasRanks() && !ranks.name.isEmpty {
                    Picker("Rank", selection: $viewModel.selectedGameRank) {
                            ForEach(ranks.getRanksForGame()){ rank in
                                Text(rank.rankName)
                                    .tag(rank as Rank?)
                            }
                        }
                    }
                }
    
                TextField("Game ID", text: $viewModel.gameID)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                    .textInputAutocapitalization(.never)
                    .onChange(of: viewModel.gameID) { _ in
                        viewModel.gameID = String(viewModel.gameID.prefix(25))
                    }
            }

            Section {
                Button {
                    Task {
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
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct AddPlayerGameProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerGameProfileSheet(viewModel: PlayerProfileViewModel())
            .environmentObject(EventsManager())
    }
}
