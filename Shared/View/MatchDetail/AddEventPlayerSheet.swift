//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventPlayerSheet: View {

    @EnvironmentObject var eventDetailManager: EventDetailManager
    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            if !viewModel.availablePlayers.isEmpty{
                List {
                    Section{
                        ForEach(viewModel.availablePlayers) { player in
                            AddPlayerListCell(checkedOffPlayers: $viewModel.checkedOffPlayers, eventGame: viewModel.event.eventGame, player: player)
                        }
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
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.checkedOffPlayers.isEmpty {
                    Button("Add Players") {
                        viewModel.addCheckedPlayersToTeam()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.getAvailablePlayers(eventDetailManager: eventDetailManager)
        }
    }
}

//struct AddEventPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEventPlayerSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: [], event: TUEvent(record: MockData.event)), team: TUTeam(record: MockData.team))
//    }
//}
