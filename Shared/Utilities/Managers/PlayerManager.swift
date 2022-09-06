//
//  PlayerManager.swift
//  TeamUp
//
//  Created by Noé Duran on 9/5/22.
//

import CloudKit
import SwiftUI

//MARK: PlayersManager
@MainActor final class PlayerManager: ObservableObject {

    var iCloudRecord: CKRecord?
    var playerProfileRecord: CKRecord?
    @Published var playerProfile: TUPlayer?
    @Published var playerGameProfiles: [TUPlayerGameProfile] = []
    @Published var eventsParticipating: [TUEvent] = []

    @Published var playerUsername: String        = ""
    @Published var playerSchool: String          = SchoolLibrary.data.schools.first!
    @Published var playerFirstName: String       = ""
    @Published var playerLastName: String        = ""

    @Published var tappedGameProfile: TUPlayerGameProfile?

    @Published var gameID: String                = ""
    @Published var selectedGame: Game            = GameLibrary.data.games[1]
    @Published var selectedGameVariant: Game?
    @Published var selectedGameRank: Rank?

    @Published var isEditingGameProfile          = false
    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))
    
    @Environment(\.dismiss) var dismiss

    func resetRankList(for game: Game){
        let gameRanks = game.getRanksForGame()
        if !gameRanks.isEmpty {
            selectedGameRank = gameRanks[0]
        } else {
            selectedGameRank = nil
        }
    }

    func resetInput(){
        gameID              = ""
        selectedGame        = GameLibrary.data.games[1]
        selectedGameVariant = nil
        selectedGameRank    = nil
    }

    private func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty else { return false }
        return true
    }

    private func isValidPlayer() async throws -> Bool {
        let usernameRegex = "([A-Za-z0-9])\\w+"
        let nameRegex = "([A-Za-z])\\w+"
        let isValidUsernameString   =  NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: playerUsername)
        let isValidFirstNameString  =  NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: playerFirstName)
        let isValidLastNameString   =  NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: playerLastName)

        let userExists = try await CloudKitManager.shared.checkUsernameExists(for: playerUsername)
        if userExists || !isValidUsernameString {
            alertItem = AlertContext.invalidUsername
            return false
        }

        if (playerFirstName.isEmpty || playerLastName.isEmpty) || !isValidFirstNameString || !isValidLastNameString {
            //MARK: Make a more meaningful alert
            alertItem = AlertContext.emptyNamePlayerProfile
            return false
        }

        return true
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)

        if let gameVariant = selectedGameVariant {
            playerGameProfile[TUPlayerGameProfile.kGameVariantName] = gameVariant.name
        }
        if let gameRank = selectedGameRank {
            playerGameProfile[TUPlayerGameProfile.kGameRank]    = gameRank.rankName
        }

        playerGameProfile[TUPlayerGameProfile.kGameName]        = selectedGame.name
        playerGameProfile[TUPlayerGameProfile.kGameID]          = gameID
        playerGameProfile[TUPlayerGameProfile.kGameAliases]     = ["",""]

        return playerGameProfile
    }

    private func createPlayerRecord() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kUsername]         = playerUsername
        playerRecord[TUPlayer.kInSchool]         = playerSchool
        playerRecord[TUPlayer.kFirstName]        = playerFirstName
        playerRecord[TUPlayer.kLastName]         = playerLastName
        playerRecord[TUPlayer.kIsGameLeader]     = 0
        playerRecord[TUPlayer.kIsVerfiedStudent] = 0

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

        //Creates CKRecord from profile view
        let playerRecord = createPlayerRecord()

        guard let userRecord = iCloudRecord else {
            print("NO RECORD")
            alertItem = AlertContext.unableToGetUserRecord
            isShowingAlert = true
            return
        }

        //Creates reference on UserRecord to TUPlayer we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: playerRecord.recordID, action: .none)

        Task {
            do {
                let _ = try await CloudKitManager.shared.batchSave(records: [userRecord,playerRecord])

                playerProfile = TUPlayer(record: playerRecord)
            } catch {
                alertItem = AlertContext.unableToCreatePlayer
                isShowingAlert = true
            }
        }
    }
    private func getGameProfiles(){
        Task{
            do {
                try await getPlayerGameProfiles()
            } catch {
                alertItem = AlertContext.unableToGetUserGameProfiles
                isShowingAlert = true
            }
        }
    }

    func getEventsParticipating(){
        Task {
            do {
                //MARK: ERROR - Unexpectedly found nil (Cause: No/Slow internet connection)
                guard let record = playerProfile else {
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

                eventsParticipating = mappedRecords.map(TUEvent.init).sorted(by: {$0.eventStartDate < $1.eventStartDate})
            } catch {
                alertItem = AlertContext.unableToFetchEventsParticipating
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
                isEditingGameProfile = false
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    func saveGameProfile(){
        guard isValidGameProfile() else {
            alertItem = AlertContext.invalidGameProfile
            isShowingAlert = true
            return
        }

        Task{
            do {
                guard let playerProfileID = playerProfile else {
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
                isPresentingSheet = false
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    func deleteProfile(){
        Task{
            do {
                guard let playerRecord = playerProfile else { return }
                let _ = try await CloudKitManager.shared.remove(recordID: playerRecord.id)

                guard let userRecord = iCloudRecord else {
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

    nonisolated func deleteGameProfile(for profile: TUPlayerGameProfile) async{
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: profile.id)

                await MainActor.run{
                    isEditingGameProfile = false
                    playerGameProfiles.removeAll(where: {$0.id == profile.id})
                }
            } catch {
                await MainActor.run {
                    alertItem = AlertContext.unableToDeleteGameProfile
                    isShowingAlert = true
                }
            }
        }
    }
    

    //MARK: CLOUDKIT

    //
    // Retrieves user record from iCloud
    // Fetches user record from CloudKit
    // Fetches TUPlayer record using user record
    // Fetches game profiles
    //
    
    func getRecordAndPlayerProfile() async {
        Task{
            do {
                let recordID = try await CloudKitManager.shared.container.userRecordID()
                let record = try await CloudKitManager.shared.container.publicCloudDatabase.record(for: recordID)
                iCloudRecord = record

                if let profileReference = record["userProfile"] as? CKRecord.Reference {
                    playerProfileRecord = try await CloudKitManager.shared.fetchRecord(with: profileReference.recordID)
                    playerProfile = TUPlayer(record: playerProfileRecord!)
                    getGameProfiles()
               }
            } catch {
                alertItem = AlertContext.unableToGetUserRecord
                isShowingAlert = true
            }
        }
    }

    //
    // Retrieves game profiles for player
    //

    func getPlayerGameProfiles() async throws {
        let sortDescriptor = NSSortDescriptor(key: TUPlayerGameProfile.kGameName, ascending: true)
        
        guard let profileRecordID = playerProfile else {
            playerGameProfiles = []
            return
        }

        let reference = CKRecord.Reference(recordID: profileRecordID.id, action: .none)
        let predicate = NSPredicate(format: "associatedToPlayer == %@", reference)
        let query = CKQuery(recordType: RecordType.playerGameProfiles, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await CloudKitManager.shared.container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}

        playerGameProfiles = records.map(TUPlayerGameProfile.init)
    }
}
