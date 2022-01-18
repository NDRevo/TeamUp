//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventPlayer: View {

    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            List {
                Section{
                    Button {
                        viewModel.addCheckedPlayersToTeam(with: team.id)
                        dismiss()
                    } label: {
                        Text("Add Players")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section{
                    ForEach(viewModel.playersInEvent) { player in
                        ExistingPlayerListCell(viewModel: viewModel, player: player)
                            .onTapGesture {
                                
                            }
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

struct AddEventPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AddEventPlayer(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: []), team: TUTeam(record: MockData.team))
    }
}
