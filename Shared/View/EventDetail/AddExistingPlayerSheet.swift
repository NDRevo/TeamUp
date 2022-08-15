//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI
import CloudKit

//MARK: AddExistingPlayerSheet
//INFO: Displays a sheet for event owners to search for a player and add them to the event
struct AddExistingPlayerSheet: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack{
            if !viewModel.availablePlayers.isEmpty {
                List {
                    Section{
                        ForEach(viewModel.availablePlayers) { player in
                            AddPlayerListCell(checkedOffPlayers: $viewModel.checkedOffPlayers, eventGame: viewModel.event.eventGameName, player: player)
                        }
                    }
                }
            }
//MARK: Fix
//                VStack(spacing: 12) {
//                    Image(systemName: "person.3")
//                        .font(.system(size: 36))
//                        .foregroundColor(.secondary)
//                    Text("No available players")
//                        .foregroundColor(.secondary)
//                }.offset(y: -64)
    
        }
        .searchable(text: $viewModel.searchString)
        .onSubmit(of: .search){
            viewModel.getSearchedPlayers(with: viewModel.searchString)
        }
        .onAppear {
            viewModel.checkedOffPlayers = []
            viewModel.availablePlayers = []
        }
        .onDisappear{
            //MARK: When user tabs out of this view, it will return to EventDetailView
            //MARK: Users may not be happy, idc for now
            dismiss()
        }
        .submitLabel(.search)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.checkedOffPlayers.isEmpty {
                    Button("Add Players") {
                        viewModel.addCheckedPlayersToEvent()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddExistingPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddExistingPlayerSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
            .environmentObject(EventsManager())
    }
}
