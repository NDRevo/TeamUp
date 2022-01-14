//
//  PlayerListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct PlayerListView: View {

    @EnvironmentObject var eventsManager: EventsManager

    @State var isShowingAddPlayerSheet = false
    
    var body: some View {
        List{
            ForEach(eventsManager.players){ player in
                Text(player.name)
            }
            .onDelete { index in
                eventsManager.players.remove(atOffsets: index)
            }
            
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Players")
        .sheet(isPresented: $isShowingAddPlayerSheet, content: {
            NavigationView {
                AddPlayerSheet()
                    .toolbar { Button("Dismiss") { isShowingAddPlayerSheet = false } }
                    .navigationTitle("Create Player")
            }
        })
        .toolbar {
            ToolbarItem(placement:.navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement:.navigationBarTrailing) {
                Button {
                    isShowingAddPlayerSheet = true
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
