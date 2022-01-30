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
    @Published var playerDetails: [TUPlayerGameDetails] = []
    
    init(player: TUPlayer, playerDetails: [TUPlayerGameDetails] = []){
        self.player         = player
        self.playerDetails  = playerDetails
    }
    
    @Published var gameID: String           = ""
    @Published var selectedGame: Games      = .valorant
    @Published var playerGameRank: String   = ""
    
    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var isShowingConfirmationDialogue = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    
    private func createPlayerGameDetail() -> CKRecord {
        let playerGameDetails = CKRecord(recordType: RecordType.playerGameDetails)
        playerGameDetails[TUPlayerGameDetails.kGameName]    = selectedGame.rawValue
        playerGameDetails[TUPlayerGameDetails.kGameRank]    = playerGameRank
        playerGameDetails[TUPlayerGameDetails.kGameID]      = gameID

        return playerGameDetails
    }
    
    func resetInput(){
        gameID          = ""
        playerGameRank  = ""
    }
    
    func isValidGameDetail() -> Bool {
        guard !gameID.isEmpty, !playerGameRank.isEmpty else {
            return false
        }
        return true
    }
    
    func getPlayersAndDetails(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.playerDetails = try await CloudKitManager.shared.getPlayersAndDetails()
            } catch {
                alertItem = AlertContext.unableToGetPlayerDetails
                isShowingAlert = true
            }
        }
    }

    func saveGameDetail(to eventsManager: EventsManager){
        guard isValidGameDetail() else {
            alertItem = AlertContext.invalidGameProfile
            isShowingAlert = true
            return
        }

        Task{
            do {
                let playerGameDetail = createPlayerGameDetail()
                playerGameDetail[TUPlayerGameDetails.kAssociatedToPlayer] = CKRecord.Reference(recordID: player.id, action: .deleteSelf)
                let _ = try await CloudKitManager.shared.save(record: playerGameDetail)

                let newPlayerProfile = TUPlayerGameDetails(record: playerGameDetail)

                eventsManager.playerDetails[player.id]?.append(newPlayerProfile)
                playerDetails.sort(by: {$0.gameName < $1.gameName})
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }
    
    func deleteGameDetail(for gameDetailRecordID: CKRecord.ID, eventsManager: EventsManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: gameDetailRecordID)
               
                playerDetails.removeAll(where: {$0.id == gameDetailRecordID})
                eventsManager.playerDetails[player.id]?.removeAll(where: {$0.id == gameDetailRecordID})
            } catch {
                
                //FIX
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}