//
//  PlayerListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct PlayerListView: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = PlayerListViewModel()
    
    var body: some View {
        List{
            ForEach(eventsManager.players){ player in
                Text(player.firstName)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let recordID = eventsManager.players[index].id
                    viewModel.deletePlayer(recordID: recordID)
                    eventsManager.players.remove(at: index)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Players")
        .sheet(isPresented: $viewModel.isShowingAddPlayerSheet, content: {
            NavigationView {
                AddPlayerSheet(viewModel: viewModel)
            }
        })
        .toolbar {
            ToolbarItem(placement:.navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement:.navigationBarTrailing) {
                Button {
                    viewModel.isShowingAddPlayerSheet = true
                } label: {
                    Text("Create Player")
                }
            }
        }
        .task {
            viewModel.getPlayers(for: eventsManager)
        }
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
