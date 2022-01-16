//
//  TeamUpApp.swift
//  Shared
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

@main
struct TeamUpApp: App {

    let eventsManager = EventsManager()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(eventsManager)
        }
    }
}
