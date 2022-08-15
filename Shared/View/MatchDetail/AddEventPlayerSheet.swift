//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

//MARK: AddEventPlayerSheet
//INFO: Displays a sheet with a list of players participating in the event that owners can pick and choose to add to a team
struct AddEventPlayerSheet: View {

    @EnvironmentObject var eventDetailViewModel: EventDetailViewModel
    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            if !viewModel.availablePlayers.isEmpty{
                List {
                    Section{
                        ForEach(viewModel.availablePlayers) { player in
                            AddPlayerListCell(checkedOffPlayers: $viewModel.checkedOffPlayers, eventGame: viewModel.event.eventGameName, player: player)
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
                        .bold()
                }.offset(y: -64)
            }
        }
        .navigationTitle("Add Player")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dismiss") {dismiss()}
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
            viewModel.getAvailablePlayers(eventDetailViewModel: eventDetailViewModel)
        }
    }
}

struct AddEventPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        //EventDetailViewModel not implemented
        AddEventPlayerSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)))
    }
}
