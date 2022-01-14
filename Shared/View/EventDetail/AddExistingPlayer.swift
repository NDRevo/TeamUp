//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI

struct AddExistingPlayer: View {

    @EnvironmentObject var manager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    @State private var selectedPlayers = Set<UUID>()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            List(manager.players, selection: $selectedPlayers) {
                    Text($0.name)
            }
            Section{
                Button {
                    compare(selectedPlayers: Array(selectedPlayers))
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Add Player")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
               EditButton()
            }
        }
    }

    func compare(selectedPlayers: [UUID]){
        for player in manager.players {
            for selectedPlayer in selectedPlayers {
                if player.id == selectedPlayer {
                    viewModel.players.append(player)
                }
            }
        }
    }
}

struct AddExistingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AddExistingPlayer(viewModel: EventDetailViewModel())
    }
}
