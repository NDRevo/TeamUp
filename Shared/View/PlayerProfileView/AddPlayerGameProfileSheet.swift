//
//  AddPlayerGameProfileSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI

struct AddPlayerGameProfileSheet: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section{
                Picker("Game", selection: $viewModel.selectedGame) {
                    ForEach(Games.allCases[1...], id: \.self){ game in
                        Text(game.rawValue)
                    }
                }
                .pickerStyle(.menu)

                TextField("Game ID", text: $viewModel.gameID)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                    .textInputAutocapitalization(.never)

                Picker("Rank", selection: $viewModel.playerGameRank) {
                    ForEach(eventsManager.getRanksForGame(game: viewModel.selectedGame), id: \.self){ rank in
                        Text(rank)
                    }
                }
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
