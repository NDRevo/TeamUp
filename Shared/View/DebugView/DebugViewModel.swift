//
//  DebugViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class DebugViewModel: ObservableObject {

    @Published var players: [TUPlayer]      = []

    @Published var playerUsername: String   = ""
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
        playerRecord[TUPlayer.kUsername]        = playerUsername
        playerRecord[TUPlayer.kFirstName]       = playerFirstName
        playerRecord[TUPlayer.kLastName]        = playerLastName
        playerRecord[TUPlayer.kIsClubLeader]    = ClubLeaderStatus.notClubLeader.rawValue

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
                players.append(TUPlayer(record: playerRecord))
                players.sort(by: {$0.firstName < $1.firstName})
                isShowingAddPlayerSheet = false
            } catch {
                alertItem = AlertContext.unableToCreatePlayer
                isShowingAlert = true
            }
        }
    }

    func getPlayers(){
        Task {
            do {
                players = try await CloudKitManager.shared.getPlayers()
            } catch {
                alertItem = AlertContext.unableToGetPlayerList
                isShowingAlert = true
            }
        }
    }

    func changeClubLeaderRequestStatusTo(to status: ClubLeaderStatus, for player: TUPlayer){
        Task{
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                if status == .notClubLeader {
                    playerRecord[TUPlayer.kClubLeaderClubName] = nil
                    playerRecord[TUPlayer.kClubLeaderRequestDescription] = nil
                    playerRecord[TUPlayer.kIsClubLeader] = status.rawValue
                } else {
                    playerRecord[TUPlayer.kIsClubLeader] = status.rawValue
                }
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

            } catch {
                //alertItem = AlertContext.unableToSaveGameProfile
                //isShowingAlert = true
            }
        }
    }

    func deletePlayer(recordID: CKRecord.ID, using manager: PlayerManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)

                guard let userRecord = manager.iCloudRecord else {
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
