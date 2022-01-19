//
//  AddPlayerSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

struct AddPlayerSheet: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerListViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            Section{
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("General")
            }

            Section{
                Picker("Game", selection: $viewModel.game) {
                    ForEach(Games.allCases, id: \.self){ game in
                        Text(game.rawValue)
                    }
                }
                .pickerStyle(.menu)
                TextField("Game ID", text: $viewModel.gameID)
                    .disableAutocorrection(true)
                    .keyboardType(.twitter)
                    .textInputAutocapitalization(.never)
                Picker("Rank", selection: $viewModel.playerGameRank) {
                    ForEach(eventsManager.getRanksForGame(game: viewModel.game), id: \.self){ rank in
                        Text(rank)
                    }
                }
            } header: {
                Text("Game Info")
            }
            Section {
                Button {
                    dismiss()
                    Task{
                        viewModel.createAndSavePlayer(for: eventsManager)
                    }
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Player")
        .toolbar { Button("Dismiss") { dismiss() }}
    }
}

//struct AddPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlayerSheet()
//    }
//}
