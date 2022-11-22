//
//  SettingsViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import Foundation
import CloudKit
import SwiftUI

@MainActor class SettingsViewModel: ObservableObject {

    @Published var isShowingWebsite         = false
    @Published var hasVerified: Bool        = false
    @Published var isShowingAlert           = false
    @Published var isShowingConfirmationDialogue = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    //0 = Not Game Leader
    //1 = Game Leader
    //2 = Requesting Game Leader
    //3 = Denied Game Leader

    func checkCanRemoveRole(_ myPublishedEvents: [TUEvent]) {
        //Can't delete event because you have a published event
        if !myPublishedEvents.isEmpty {
            alertItem = AlertContext.unableToRemoveGameLeaderRole
            isShowingAlert = true
        } else {
            isShowingConfirmationDialogue = true
        }
    }

    nonisolated func changeGameLeaderPosition(to value: Int, handledBy playerManager: PlayerManager) async {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerManager.playerProfile!.id)
                playerRecord[TUPlayer.kIsGameLeader] = value
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                await MainActor.run {
                    //Only values 0 and 2 will be used with this method hence:
                    if value == 0 {
                        playerManager.isRequestingGameLeader = false
                        playerManager.isGameLeader = false
                    } else if value == 2 {
                        playerManager.isRequestingGameLeader = true
                    }
                }
            } catch {
                await MainActor.run {
                    alertItem = AlertContext.unableToChangeGameLeaderPosition
                    isShowingAlert = true
                }
            }
    }

    nonisolated func changeVerificationStatus(_ hasVerified: Bool,for player: TUPlayer) async{
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                playerRecord[TUPlayer.kIsVerfiedStudent] = hasVerified ? 1 : 0
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
                
            } catch {
                await MainActor.run {
                    //MARK: Add Alert
                    isShowingAlert = true
                }
            }
    }
}
