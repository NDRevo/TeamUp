//
//  DebugView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct DebugView: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @EnvironmentObject private var playerManager: PlayerManager
    @StateObject private var viewModel = DebugViewModel()

    var body: some View {
        NavigationView {
            List{
                ForEach(viewModel.players){ player in
                        HStack{
                            VStack(alignment: .leading,spacing: appCellSpacing){
                                Text(player.username)
                                    .bold()
                                    .font(.title2)
                                
                                Text(player.clubLeaderClubName)
                                Text(player.clubLeaderRequestDescription)
                                
                                if player.isClubLeader == ClubLeaderStatus.requestClubLeader.rawValue  {
                                    HStack{
                                        Button {
                                            viewModel.changeClubLeaderRequestStatusTo(to: .clubLeader, for: player)
                                        } label: {
                                            Text("Give Leader")
                                        }
                                        Spacer()
                                        Button {
                                            viewModel.changeClubLeaderRequestStatusTo(to: .deniedClubLeader, for: player)
                                        } label: {
                                            Text("Deny Leader")
                                        }
                                    }
                                } else if player.isClubLeader == ClubLeaderStatus.deniedClubLeader.rawValue {
                                    Button {
                                        viewModel.changeClubLeaderRequestStatusTo(to: .notClubLeader, for: player)
                                    } label: {
                                        Text("Undeny Player Club Request")
                                    }
                                }
                                
                                
                            }
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recordID = viewModel.players[index].id
                        viewModel.deletePlayer(recordID: recordID, using: playerManager)

                        viewModel.players.remove(at: index)
                    }
                }
            }
            .buttonStyle(.borderless)
            .listStyle(.insetGrouped)
            .navigationTitle("Players")
            .refreshable {
                viewModel.getPlayers()
            }
            .task {
                if !viewModel.onAppearHasFired {
                    viewModel.getPlayers()
                }
                viewModel.onAppearHasFired = true
            }
            .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
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

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .environmentObject(EventsManager())
    }
}

struct PlayerListToolbarContent: ToolbarContent {

    @ObservedObject var viewModel: DebugViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement:.navigationBarLeading) {
            if !viewModel.players.isEmpty {
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
