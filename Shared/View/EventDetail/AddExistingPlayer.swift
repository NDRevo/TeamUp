//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI
import CloudKit

struct AddExistingPlayer: View {

    @EnvironmentObject var manager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            List {
                Section{
                    Button {
                        viewModel.addCheckedPlayersToEvent()
                        dismiss()
                    } label: {
                        Text("Add Players")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section{
                    ForEach(viewModel.availablePlayers) { player in
                        PlayerListCell(viewModel: viewModel, player: player)
                    }
                } header: {
                    Text("Available Players")
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
        }
    }
}

struct AddExistingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AddExistingPlayer(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
