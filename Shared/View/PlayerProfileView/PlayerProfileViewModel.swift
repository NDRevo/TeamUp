//
//  PlayerProfileViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI
import CloudKit

@MainActor final class PlayerProfileViewModel: ObservableObject {

    @Published var playerGameProfiles: [TUPlayerGameProfile] = []
    @Published var eventsParticipating: [TUEvent] = []

    @Published var playerProfile:TUPlayer?

    @Published var playerUsername: String        = ""
    @Published var playerFirstName: String       = ""
    @Published var playerLastName: String        = ""

    @Published var tappedGameProfile: TUPlayerGameProfile?

    @Published var gameID: String                = ""
    @Published var selectedGame: Game            = GameLibrary.data.games[2]
    @Published var selectedGameVariant: Game     = Game(name: "", ranks: [])
    @Published var selectedGameRank: Rank        = Rank(rankName: "", rankWeight: 0)

    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var isShowingConfirmationDialogue = false
    @Published var isEditingGameProfile          = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    @Environment(\.dismiss) var dismiss

    func resetInput(){
        gameID           = ""
        selectedGame     = GameLibrary.data.games[2]

        if !selectedGame.getRanksForGame().isEmpty {
            selectedGameRank = Rank(rankName: "Unranked", rankWeight: 0)
        } else {
            selectedGameRank = Rank(rankName: "", rankWeight: 0)
        }
    }
    
    func resetRankList(for value: Game){
        if !value.getRanksForGame().isEmpty {
            selectedGameRank = value.getRanksForGame()[0]
        } else {
            selectedGameRank = Rank(rankName: "", rankWeight: 0)
        }
    }

    private func isValidPlayer() async throws -> Bool {
        let userExists = try await CloudKitManager.shared.checkUsernameExists(for: playerUsername)

        if userExists {
            alertItem = AlertContext.invalidUsername
            return false
        }

        guard !playerFirstName.isEmpty && !playerLastName.isEmpty else {
            alertItem = AlertContext.emptyNamePlayerProfile
            return false
        }

        return true
    }

    private func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty else {
            return false
        }
        return true
    }

    func isLoggedIn() -> Bool {
        return CloudKitManager.shared.playerProfile != nil
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        if !selectedGameVariant.name.isEmpty {
            playerGameProfile[TUPlayerGameProfile.kGameVariantName] = selectedGameVariant.name
        }
        playerGameProfile[TUPlayerGameProfile.kGameName]    = selectedGame.name
        playerGameProfile[TUPlayerGameProfile.kGameRank]    = selectedGameRank.rankName
        playerGameProfile[TUPlayerGameProfile.kGameID]      = gameID
        playerGameProfile[TUPlayerGameProfile.kGameAliases]   = ["",""]

        return playerGameProfile
    }

    private func createPlayerRecord() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kUsername]        = playerUsername
        playerRecord[TUPlayer.kFirstName]       = playerFirstName
        playerRecord[TUPlayer.kLastName]        = playerLastName
        playerRecord[TUPlayer.kIsGameLeader]    = 0

        return playerRecord
    }

    func createProfile() async {
        do {
            guard try await isValidPlayer() else {
                isShowingAlert = true
                return
            }
        } catch {
            alertItem = AlertContext.unableToCheckIfValidPlayer
            isShowingAlert = true
        }

        //TIP: Create CKRecord from profile view
        let playerRecord = createPlayerRecord()

        guard let userRecord = CloudKitManager.shared.userRecord else {
            alertItem = AlertContext.unableToGetUserRecord
            isShowingAlert = true
            return
        }

        //TIP: Create reference on UserRecord to TUPlayer we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: playerRecord.recordID, action: .none)

        Task {
            do {
                let _ = try await CloudKitManager.shared.batchSave(records: [userRecord,playerRecord])

                let playerProfile = TUPlayer(record: playerRecord)
                CloudKitManager.shared.playerProfile = TUPlayer(record: playerRecord)
                self.playerProfile = playerProfile 
            } catch {
                alertItem = AlertContext.unableToCreatePlayer
                isShowingAlert = true
            }
        }
    }

    func saveGameProfile(to eventsManager: EventsManager){
        guard isValidGameProfile() else {
            alertItem = AlertContext.invalidGameProfile
            isShowingAlert = true
            return
        }

        Task{
            do {
                guard let playerProfileID = CloudKitManager.shared.playerProfile else {
                    alertItem = AlertContext.unableToGetUserProfile
                    isShowingAlert = true
                    return
                }
                let playerGameProfile = createPlayerGameProfile()
                playerGameProfile[TUPlayerGameProfile.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerProfileID.id, action: .deleteSelf)
                let _ = try await CloudKitManager.shared.save(record: playerGameProfile)

                let newPlayerProfile = TUPlayerGameProfile(record: playerGameProfile)

                playerGameProfiles.append(newPlayerProfile)
                playerGameProfiles.sort(by: {$0.gameName < $1.gameName})
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    func saveEditGameProfile(of gameProfile: TUPlayerGameProfile.ID, gameID: String, gameRank: String, gameAliases: [String]){
        Task{
            do {
                let gameProfileRecord = try await CloudKitManager.shared.fetchRecord(with: gameProfile)
                
                gameProfileRecord[TUPlayerGameProfile.kGameID] = gameID
                gameProfileRecord[TUPlayerGameProfile.kGameRank] = gameRank
                gameProfileRecord[TUPlayerGameProfile.kGameAliases] = gameAliases
                let _ = try await CloudKitManager.shared.save(record: gameProfileRecord)
                
                getGameProfiles()

            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    func getEventsParticipating(){
        Task {
            do {
                //MARK: ERROR - Unexpectedly found nil (Cause: No/Slow internet connection)
                guard let record = CloudKitManager.shared.playerProfile else {
                    return
                }

                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: record.id)
                let references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []
                let recordIDFromReference = references.map({$0.recordID})

                let records = try await CloudKitManager.shared.fetchRecords(with: recordIDFromReference)
                let mappedRecords = records.values.compactMap { result in
                    switch result {
                    case .success(let data):
                        return data
                    case .failure(_):
                        return nil
                    }
                }

                eventsParticipating = mappedRecords.map(TUEvent.init).sorted(by: {$0.eventDate < $1.eventDate})
            } catch {
                alertItem = AlertContext.unableToFetchEventsParticipating
                isShowingAlert = true
            }
        }
    }

    func getProfile(){
        guard let userRecord = CloudKitManager.shared.userRecord else {
            alertItem = AlertContext.unableToGetUserRecord
            isShowingAlert = true
            return
        }

        //TIP: Get reference, if none it means they havent created a profile
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
        let profileRecordID = profileReference.recordID

        Task {
            do{
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                let player = TUPlayer(record: record)
                playerUsername    = player.username
                playerFirstName   = player.firstName
                playerLastName    = player.lastName

                getGameProfiles()
            } catch {
                alertItem = AlertContext.unableToGetUserProfile
                isShowingAlert = true
            }
        }
    }

    private func getGameProfiles(){
        Task{
            do {
                playerGameProfiles = try await CloudKitManager.shared.getPlayerGameProfiles()
            } catch {
                alertItem = AlertContext.unableToGetUserGameProfiles
                isShowingAlert = true
            }
        }
    }

    func deleteProfile(){
        Task{
            do {
                guard let playerRecord = CloudKitManager.shared.playerProfile else { return }
                let _ = try await CloudKitManager.shared.remove(recordID: playerRecord.id)
                
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    alertItem = AlertContext.unableToGetPlayerList
                    return
                }

                userRecord["userProfile"] = nil
                let _ = try await CloudKitManager.shared.save(record: userRecord)

            } catch {
                alertItem = AlertContext.failedToDeleteProfile
                isShowingAlert = true
            }
        }
    }

    func deleteGameProfile(for gameProfileRecordID: CKRecord.ID, eventsManager: EventsManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: gameProfileRecordID)

                playerGameProfiles.removeAll(where: {$0.id == gameProfileRecordID})
            } catch {
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}
