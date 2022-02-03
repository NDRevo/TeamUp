//
//  PlayerProfileViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI
import CloudKit


@MainActor final class PlayerProfileViewModel: ObservableObject {

    var player: TUPlayer
    @Published var playerProfiles: [TUPlayerGameProfile] = []

    init(player: TUPlayer, playerProfiles: [TUPlayerGameProfile] = []){
        self.player          = player
        self.playerProfiles  = playerProfiles
    }

    @Published var gameID: String           = ""
    @Published var selectedGame: Games      = .valorant
    @Published var playerGameRank: String   = ""
    
    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var isShowingConfirmationDialogue = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    func resetInput(){
        gameID          = ""
        playerGameRank  = ""
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        playerGameProfile[TUPlayerGameProfile.kGameName]    = selectedGame.rawValue
        playerGameProfile[TUPlayerGameProfile.kGameRank]    = playerGameRank
        playerGameProfile[TUPlayerGameProfile.kGameID]      = gameID

        return playerGameProfile
    }

    func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty, !playerGameRank.isEmpty else {
            return false
        }
        return true
    }

    func saveGameProfile(to eventsManager: EventsManager){
        guard isValidGameProfile() else {
            alertItem = AlertContext.invalidGameProfile
            isShowingAlert = true
            return
        }

        Task{
            do {
                let playerGameProfile = createPlayerGameProfile()
                playerGameProfile[TUPlayerGameProfile.kAssociatedToPlayer] = CKRecord.Reference(recordID: player.id, action: .deleteSelf)
                let _ = try await CloudKitManager.shared.save(record: playerGameProfile)

                let newPlayerProfile = TUPlayerGameProfile(record: playerGameProfile)

                eventsManager.playerProfiles[player.id]?.append(newPlayerProfile)
                playerProfiles.sort(by: {$0.gameName < $1.gameName})
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    func getPlayersAndProfiles(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.playerProfiles = try await CloudKitManager.shared.getPlayersAndProfiles()
            } catch {
                alertItem = AlertContext.unableToGetPlayerProfiles
                isShowingAlert = true
            }
        }
    }

    func deleteGameProfile(for gameProfileRecordID: CKRecord.ID, eventsManager: EventsManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: gameProfileRecordID)
               
                playerProfiles.removeAll(where: {$0.id == gameProfileRecordID})
                eventsManager.playerProfiles[player.id]?.removeAll(where: {$0.id == gameProfileRecordID})
            } catch {
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}
