//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI
import CloudKit

//MARK: AddPlayerToEventSheet
//INFO: Displays a sheet for event owners to search for a player and add them to the event
struct AddPlayerToEventSheet: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack{
                if viewModel.availablePlayers.isEmpty {
                    VStack(spacing: appImageToTextEmptyContentSpacing) {
                        Image(systemName: "person.3")
                            .font(.system(size: appImageSizeEmptyContent))
                            .foregroundColor(.secondary)
                        Text("Search players by their username")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.top, 72)
                    .padding(.horizontal, appHorizontalViewPadding)
                } else {
                    List {
                        ForEach(viewModel.availablePlayers) { player in
                            AddPlayerListCell(checkedOffPlayers: $viewModel.checkedOffPlayers, eventGame: viewModel.event.eventGameName, player: player)
                        }
                    }
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            //Can't add horizontal padding, would affect the search bar
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
        
            .toolbar {
                ToolbarItem(placement:.cancellationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
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
}

struct AddExistingPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerToEventSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
            .environmentObject(EventsManager())
    }
}
