//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventPlayerSheet: View {

    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var team: TUTeam

    var body: some View {
        VStack{
            if !viewModel.availablePlayers.isEmpty{
                List {
                    if !viewModel.checkedOffPlayers.isEmpty{
                        Section{
                            Button {
                                viewModel.addCheckedPlayersToTeam(with: team.id)
                                dismiss()
                            } label: {
                                Text("Add Players")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                    Section{
                        ForEach(viewModel.availablePlayers) { player in
                            ExistingPlayerListCell(viewModel: viewModel, player: player)
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
                Button("Dismiss") { dismiss() }
            }
        }
        .task {
            viewModel.getAvailablePlayers()
        }
    }
}

//struct AddEventPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEventPlayerSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: [], event: TUEvent(record: MockData.event)), team: TUTeam(record: MockData.team))
//    }
//}
