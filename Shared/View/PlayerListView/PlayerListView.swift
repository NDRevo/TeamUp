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
        .task {
            viewModel.getPlayers(for: eventsManager)
        }
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
                    viewModel.resetInput()
                } label: {
                    Text("Create Player")
                }
            }
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
