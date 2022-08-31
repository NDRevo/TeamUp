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
    @Published var playerSchool: String          = SchoolLibrary.data.schools.first!
    @Published var playerFirstName: String       = ""
    @Published var playerLastName: String        = ""

    @Published var tappedGameProfile: TUPlayerGameProfile?

    @Published var gameID: String                = ""
    @Published var selectedGame: Game            = GameLibrary.data.games[1]
    @Published var selectedGameVariant: Game?
    @Published var selectedGameRank: Rank?

    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var isShowingConfirmationDialogue = false
    @Published var isEditingGameProfile          = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    @Environment(\.dismiss) var dismiss

    func resetInput(){
        gameID              = ""
        selectedGame        = GameLibrary.data.games[1]
        selectedGameVariant = nil
        selectedGameRank = nil
    }
    
    func resetRankList(for game: Game){
        let gameRanks = game.getRanksForGame()
        if !gameRanks.isEmpty {
            selectedGameRank = gameRanks[0]
        } else {
            selectedGameRank = nil
        }
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

    private func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty else {
            return false
        }
        return true
    }

    func loggedIntoiCloud() -> Bool {
        return CloudKitManager.shared.userRecord != nil
    }

    func isLoggedIn() -> Bool {
        return CloudKitManager.shared.playerProfile != nil
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        if let gameVariant = selectedGameVariant {
            playerGameProfile[TUPlayerGameProfile.kGameVariantName] = gameVariant.name
        }
        playerGameProfile[TUPlayerGameProfile.kGameName]    = selectedGame.name
        if let gameRank = selectedGameRank {
            playerGameProfile[TUPlayerGameProfile.kGameRank]  = gameRank.rankName
        }
        playerGameProfile[TUPlayerGameProfile.kGameID]      = gameID
        playerGameProfile[TUPlayerGameProfile.kGameAliases]   = ["",""]

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

    //Async func to check database if username exist
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

        guard let userRecord = CloudKitManager.shared.userRecord else {
            alertItem = AlertContext.unableToGetUserRecord
            isShowingAlert = true
            return
        }

        //Creates reference on UserRecord to TUPlayer we created
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
                isPresentingSheet = false
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
                isEditingGameProfile = false
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

                eventsParticipating = mappedRecords.map(TUEvent.init).sorted(by: {$0.eventStartDate < $1.eventStartDate})
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

        //Get reference, if none it means they havent created a profile
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
                //Two Issues
                //If CloudKit issue or internet issue with an existing profile, there should be an alert
                //If there is no profile found for the icloud user than dont show alert
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
                isEditingGameProfile = false
            } catch {
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}
