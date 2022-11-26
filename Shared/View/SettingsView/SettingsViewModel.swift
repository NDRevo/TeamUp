//
//  SettingsViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import Foundation
import CloudKit
import SwiftUI

enum ClubLeaderStatus: Int {
    case notClubLeader = 0
    case clubLeader = 1
    case requestClubLeader = 2
    case deniedClubLeader = 3
}

@MainActor class SettingsViewModel: ObservableObject {

    @Published var clubLeaderClubName: String = ""
    @Published var clubLeaderRequestDescription: String = ""

    @Published var isShowingWebsite         = false
    @Published var hasVerified: Bool        = false
    @Published var isShowingAlert           = false
    @Published var isShowingConfirmationDialogue = false
    @Published var isShowingRequestClubLeaderSheet = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    func checkCanRemoveRole(_ myPublishedEvents: [TUEvent]) {
        //Can't delete event because you have a published event
        if !myPublishedEvents.isEmpty {
            alertItem = AlertContext.unableToRemoveClubLeaderRole
            isShowingAlert = true
        } else {
            isShowingConfirmationDialogue = true
        }
    }

    nonisolated func changeClubLeaderPosition(to value: Int, handledBy playerManager: PlayerManager) async {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerManager.playerProfile!.id)
                playerRecord[TUPlayer.kIsClubLeader] = value

                if value == 2 {
                    playerRecord[TUPlayer.kClubLeaderClubName] = await clubLeaderClubName
                    playerRecord[TUPlayer.kClubLeaderRequestDescription] = await clubLeaderRequestDescription
                } else if value == 0 {
                    playerRecord[TUPlayer.kClubLeaderClubName] = nil
                    playerRecord[TUPlayer.kClubLeaderRequestDescription] = nil
                    
                    //We don't nil out for denied (3) if we need to review request again
                }

                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                await MainActor.run {
                    //Only values 0 and 2 will be used with this method hence:
                    if value == 0 {
                        playerManager.isClubLeader = .notClubLeader
                    } else if value == 2 {
                        playerManager.isClubLeader = .requestClubLeader
                    }
                }
            } catch {
                await MainActor.run {
                    alertItem = AlertContext.unableToChangeClubLeaderPosition
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
