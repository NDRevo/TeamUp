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
            PlayerListView()
                .tabItem {
                    Label("Players", systemImage: "person.3.fill")
                }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
