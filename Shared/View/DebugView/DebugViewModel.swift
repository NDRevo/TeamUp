//
//  PlayerListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class DebugViewModel: ObservableObject {

    @Published var playerFirstName: String  = ""
    @Published var playerLastName: String   = ""

    @Published var isShowingAddPlayerSheet  = false
    @Published var isShowingAlert           = false
    @Published var onAppearHasFired         = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    func resetInput(){
        playerFirstName = ""
        playerLastName  = ""
    }

    private func createPlayer() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]       = playerFirstName
        playerRecord[TUPlayer.kLastName]        = playerLastName
        playerRecord[TUPlayer.kIsGameLeader]    = 0

        return playerRecord
    }

    private func isValidPlayer() -> Bool{
        guard !playerFirstName.isEmpty else {
            return false
        }
        return true
    }

    func createAndSavePlayer(for eventsManager: EventsManager){
        guard isValidPlayer() else {
            alertItem = AlertContext.invalidPlayer
            isShowingAlert = true
            return
        }

        Task{
            do {
                let playerRecord = createPlayer()
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                //Reloads view, locally adds player until another network call is made
                eventsManager.players.append(TUPlayer(record: playerRecord))
                eventsManager.players.sort(by: {$0.firstName < $1.firstName})
            } catch {
                alertItem = AlertContext.unableToCreatePlayer
                isShowingAlert = true
            }
        }
    }

    func getPlayers(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.players = try await CloudKitManager.shared.getPlayers()
            } catch {
                alertItem = AlertContext.unableToGetPlayerList
                isShowingAlert = true
            }
        }
    }

    func deletePlayer(recordID: CKRecord.ID){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)
                
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    alertItem = AlertContext.unableToGetPlayerList
                    return
                }

                userRecord["userProfile"] = nil
                let _ = try await CloudKitManager.shared.save(record: userRecord)
            } catch {
                alertItem = AlertContext.unableToDeletePlayer
                isShowingAlert = true
            }
        }
    }
}
