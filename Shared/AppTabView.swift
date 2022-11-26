//
//  AppTabView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct AppTabView: View {

    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventsManager: EventsManager

    var body: some View {
        TabView {
            EventsListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            //INFO: If user is a game leader, they have access to this tab to create events
            if playerManager.isClubLeader == .clubLeader {
                MyEventsView()
                    .tabItem {
                        Label("My Events", systemImage: "slider.horizontal.2.square.on.square")
                    }
            }
            PlayerProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            DebugView()
                .tabItem {
                    Label("Players", systemImage: "person.3.fill")
                }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
            .environmentObject(EventsManager())
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
