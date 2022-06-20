//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI
//MainActor exists so you dont have to do Dispatch.Main.async{}
@MainActor final class EventsListViewModel: ObservableObject {

    @Published var onAppearHasFired          = false
    @Published var isPresentingAddEvent      = false
    @Published var isShowingAlert            = false

    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    func refresh(for eventsManager: EventsManager){
        getPlayers(for: eventsManager)
        getPlayersAndProfiles(for: eventsManager)
    }

    func startUp(for eventsManager: EventsManager){
        //FIX
        //Forces app to call this once, but would force user to pull to refresh to get new events
        //Fixed flashing list cell
        if !onAppearHasFired {
            getPlayers(for: eventsManager)
            getPlayersAndProfiles(for: eventsManager)
        }
        onAppearHasFired = true
    }

    private func getPlayers(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.players = try await CloudKitManager.shared.getPlayers()
            } catch {
                alertItem = AlertContext.unableToGetPlayerList
                isShowingAlert = true
            }
        }
    }

    private func getPlayersAndProfiles(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.playerProfiles = try await CloudKitManager.shared.getPlayersAndProfiles()
            } catch {
                alertItem = AlertContext.unableToGetPlayerProfiles
                isShowingAlert = true
            }
        }
    }
}
