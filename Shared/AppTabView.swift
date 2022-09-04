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
                    Label("Events", systemImage: "calendar")
                }
            //INFO: If user is a game leader, they have access to this tab to create events
            if let record = CloudKitManager.shared.playerProfile {
                if record.isGameLeader == 1{
                    MyEventsView()
                        .tabItem {
                            Label("My Events", systemImage: "slider.horizontal.2.square.on.square")
                        }
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
            CoreDataDebugView()
                .tabItem {
                    Label("Core Data", image: "gear")
                }
        }
        .task {
            do {
                eventsManager.userProfile = try await CloudKitManager.shared.getUserRecord()
            } catch {}
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
            .environmentObject(EventsManager())
    }
}
