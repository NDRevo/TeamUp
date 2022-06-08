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
            PlayerProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            PlayerListView()
                .tabItem {
                    Label("Players", systemImage: "person.3.fill")
                }
        }
        .task {
            try? await CloudKitManager.shared.getUserRecord()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
            .environmentObject(EventsManager())
    }
}
