//
//  PlayerListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class PlayerListViewModel: ObservableObject {

    @Published var playerFirstName: String  = ""
    @Published var playerLastName: String   = ""

    //HANDLE LATER: Stop app from calling getPlayers() twice in .task modifier: Swift Bug
    @Published var isShowingAddPlayerSheet   = false
    @Published var isShowingAlert            = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    func resetInput(){
        playerFirstName = ""
        playerLastName  = ""
    }

    private func createPlayer() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]   = playerFirstName
        playerRecord[TUPlayer.kLastName]    = playerLastName
        
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
            } catch {
                alertItem = AlertContext.unableToDeletePlayer
                isShowingAlert = true
            }
        }
    }
}
