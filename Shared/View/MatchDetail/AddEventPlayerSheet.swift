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
                    }
                } header: {
                    Text("Available Players")
                }
            }
        }
        .navigationTitle("Add Player")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") { dismiss() }
            }
        }
    }
}

//struct AddEventPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEventPlayerSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: [], event: TUEvent(record: MockData.event)), team: TUTeam(record: MockData.team))
//    }
//}
