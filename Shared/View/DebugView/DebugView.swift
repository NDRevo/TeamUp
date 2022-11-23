//
//  DebugView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct DebugView: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = DebugViewModel()

    var body: some View {
        NavigationView {
            List{
                ForEach(eventsManager.players){ player in
                        HStack{
                            VStack(alignment: .leading){
                                Text(player.username)
                                    .bold()
                                    .font(.title2)
                                
                                Spacer()
                                
                                if player.isGameLeader == 2 {
                                    Button {
                                        viewModel.giveGameLeader(to: player)
                                    } label: {
                                        Text("Give Leader")
                                    }

                                }
                                
                                
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
                if !viewModel.onAppearHasFired {
                    viewModel.getPlayers(for: eventsManager)
                }
                viewModel.onAppearHasFired = true
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .toolbar {
                PlayerListToolbarContent(viewModel: viewModel, playerList: eventsManager.players)
            }
            .sheet(isPresented: $viewModel.isShowingAddPlayerSheet){
                NavigationView {
                    AddPlayerSheet(viewModel: viewModel)
                }
            }
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .environmentObject(EventsManager())
    }
}

struct PlayerListToolbarContent: ToolbarContent {

    @ObservedObject var viewModel: DebugViewModel
    var playerList: [TUPlayer]

    var body: some ToolbarContent {
        ToolbarItem(placement:.navigationBarLeading) {
            if !playerList.isEmpty {
                EditButton()
            }
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
