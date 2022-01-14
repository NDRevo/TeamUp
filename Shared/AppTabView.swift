//
//  AppTabView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct AppTabView: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    
    var body: some View {
        TabView {
            EventsListView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            NavigationView{
                PlayerListView()
            }
            .tabItem {
                Label("Players", systemImage: "person.3.fill")
            }
        }
        .task{
            Task{
                do{
                    eventsManager.players = try await CloudKitManager.shared.getPlayers()
                }catch {
                    //Alert
                }
            }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
