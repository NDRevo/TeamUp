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

    @Published var playerFirstName: String       = ""
    @Published var playerLastName: String        = ""

    @Published var gameID: String                = ""
    @Published var selectedGame: Games           = .apexlegends
    @Published var playerGameRank: String        = ""

    @Published var isPresentingSheet             = false
    @Published var isShowingAlert                = false
    @Published var isShowingConfirmationDialogue = false
    @Published var isEditingGameProfile          = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert.")) //MARK: DidSet

    func resetInput(){
        selectedGame    = Games.apexlegends //First game alphabetically
        gameID          = ""
        playerGameRank  = ""
    }

    private func isValidPlayer() -> Bool {
        guard !playerFirstName.isEmpty && !playerLastName.isEmpty else {
            return false
        }
        return true
    }

    private func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty, !playerGameRank.isEmpty else {
            return false
        }
        return true
    }

    func isLoggedIn() -> Bool {
        return CloudKitManager.shared.profileRecordID != nil
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        playerGameProfile[TUPlayerGameProfile.kGameName]    = selectedGame.rawValue
        playerGameProfile[TUPlayerGameProfile.kGameRank]    = playerGameRank
        playerGameProfile[TUPlayerGameProfile.kGameID]      = gameID
        playerGameProfile[TUPlayerGameProfile.kGameAliases]   = ["",""]

        return playerGameProfile
    }

    private func createPlayerRecord() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]   = playerFirstName
        playerRecord[TUPlayer.kLastName]    = playerLastName
        
        return playerRecord
    }

    func createProfile(){
        guard isValidPlayer() else {
            //Invalid Profiles
            alertItem = AlertContext.invalidPlayer
            return
        }
        //Create CKRecord from profile view
        let playerRecord = createPlayerRecord()
        
        guard let userRecord = CloudKitManager.shared.userRecord else {
            //unable to get user record
            alertItem = AlertContext.unableToGetPlayerProfiles
            return
        }

        //Create reference on UserRecord to TUPlayer we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: playerRecord.recordID, action: .none)

        Task {
            do {
                let records = try await CloudKitManager.shared.batchSave(records: [userRecord,playerRecord])
                for record in records where record.recordType == RecordType.player {
                    //Makes sure to update profileRecordID when first creating a profile
                    CloudKitManager.shared.profileRecordID = record.recordID
                }
                //Successfully
                alertItem = AlertContext.invalidGameProfile
            } catch {
                //Unsuccessful
                alertItem = AlertContext.invalidPlayer
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
                guard let playerProfileID = CloudKitManager.shared.profileRecordID else {
                    return
                    //Alert
                }
                let playerGameProfile = createPlayerGameProfile()
                playerGameProfile[TUPlayerGameProfile.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerProfileID, action: .deleteSelf)
                let _ = try await CloudKitManager.shared.save(record: playerGameProfile)

                let newPlayerProfile = TUPlayerGameProfile(record: playerGameProfile)

                eventsManager.playerProfiles[playerProfileID]?.append(newPlayerProfile)
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
                //MARK: Make Alert
            }
        }
    }

    func getEventsParticipating(){
        Task {
            do {
                //MARK: ERROR - Unexpectedly found nil (Cause: No/Slow internet connection)
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: CloudKitManager.shared.profileRecordID!)
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
                //MARK: Make Alert
            }
        }
    }

    func getProfile(){
        guard let userRecord = CloudKitManager.shared.userRecord else {
            //No user record found
            alertItem = AlertContext.unableToGetPlayerList
            return
        }

        //Get reference, if none it means they havent created a profile
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
        let profileRecordID = profileReference.recordID

        Task {
            do{
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                let player = TUPlayer(record: record)
                playerFirstName   = player.firstName
                playerLastName    = player.lastName

                getGameProfiles()
            } catch {
                //MARK: Make Alert
            }
        }
    }

    private func getGameProfiles(){
        Task{
            do {
                playerGameProfiles = try await CloudKitManager.shared.getPlayerGameProfiles()
            } catch {
                //MARK: Make Alert
            }
        }
    }

    func deleteProfile(){
        Task{
            do {
                guard let playerRecord = CloudKitManager.shared.profileRecordID else { return }
                let _ = try await CloudKitManager.shared.remove(recordID: playerRecord)
                
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    alertItem = AlertContext.unableToGetPlayerList
                    return
                }

                userRecord["userProfile"] = nil
                let _ = try await CloudKitManager.shared.save(record: userRecord)

            } catch {
                //MARK: Make Alert
            }
        }
    }

    func deleteGameProfile(for gameProfileRecordID: CKRecord.ID, eventsManager: EventsManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: gameProfileRecordID)
               
                guard let playerProfileID = CloudKitManager.shared.profileRecordID else {
                    return
                    //Alert
                }

                playerGameProfiles.removeAll(where: {$0.id == gameProfileRecordID})
                eventsManager.playerProfiles[playerProfileID]?.removeAll(where: {$0.id == gameProfileRecordID})
            } catch {
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}
