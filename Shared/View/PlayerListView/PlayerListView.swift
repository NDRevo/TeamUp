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
        NavigationView {
            List{
                ForEach(eventsManager.players){ player in
                    HStack{
                        VStack(alignment: .leading){
                            Text(player.firstName)
                                .bold()
                                .font(.title2)
                        }
                    }
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
            .refreshable {
                viewModel.getPlayers(for: eventsManager)
            }
            .task {
                viewModel.getPlayers(for: eventsManager)
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .toolbar {
                PlayerListToolbarContent(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingAddPlayerSheet){
                NavigationView {
                    AddPlayerSheet(viewModel: viewModel)
                }
            }
        }
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}

struct PlayerListToolbarContent: ToolbarContent {

    @ObservedObject var viewModel: PlayerListViewModel

    var body: some ToolbarContent {
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
}
