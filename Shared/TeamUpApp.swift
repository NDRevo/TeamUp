//
//  TeamUpApp.swift
//  Shared
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

@main
struct TeamUpApp: App {

    @StateObject var playerManager = PlayerManager()
    @StateObject var eventsManager = EventsManager()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(eventsManager)
                .environmentObject(playerManager)
                .task {
                    await playerManager.getRecordAndPlayerProfile()
                    eventsManager.getMyPublishedEvents(for: playerManager.playerProfile)
                    eventsManager.getMyUnpublishedEvents(for: playerManager.playerProfile)
                }
                //This should be displayed within all tabs and sheets
                .alert($playerManager.isShowingAlert, alertInfo: playerManager.alertItem)
        }
    }
}
