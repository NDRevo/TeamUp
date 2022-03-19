//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI
import CloudKit

struct AddExistingPlayerSheet: View {

    @EnvironmentObject var eventDetailManager: EventDetailManager
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            if !viewModel.availablePlayers.isEmpty {
                List {
                    if !viewModel.checkedOffPlayers.isEmpty {
                        Section{
                            Button {
                                viewModel.addCheckedPlayersToEvent(eventDetailManager: eventDetailManager)
                                dismiss()
                            } label: {
                                Text("Add Players")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    Section{
                        ForEach(viewModel.availablePlayers) { player in
                            PlayerListCell(viewModel: viewModel, player: player)
                        }
                    } header: {
                        Text("Available Players")
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No available players")
                        .foregroundColor(.secondary)
                }.offset(y: -64)
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
        .task {
            viewModel.getAvailablePlayers(from: eventsManager.players, eventDetailManager: eventDetailManager)
        }
    }
}

struct AddExistingPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddExistingPlayerSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
