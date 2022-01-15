//
//  PlayerListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct PlayerListView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @StateObject var viewModel = PlayerListViewModel()
    
    var body: some View {
        List{
            ForEach(eventsManager.players){ player in
                Text(player.firstName)
            }
            .onDelete { indexs in
                for index in indexs {
                    let recordID = eventsManager.players[index].id
                    viewModel.removePlayer(recordID: recordID)
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
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
