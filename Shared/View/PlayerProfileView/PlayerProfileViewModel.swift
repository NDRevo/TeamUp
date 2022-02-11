//
//  PlayerProfileViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI
import CloudKit


@MainActor final class PlayerProfileViewModel: ObservableObject {
    
    @Published var playerProfiles: [TUPlayerGameProfile] = []

    init(playerProfiles: [TUPlayerGameProfile] = []){
        self.playerProfiles  = playerProfiles
    }

    @Published var playerFirstName: String  = ""
    @Published var playerLastName: String   = ""
    
    private var existingProfileRecord: CKRecord?

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
    
    func isLoggedIn() -> Bool {
        return CloudKitManager.shared.profileRecordID != nil
    }

    private func createPlayerGameProfile() -> CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        playerGameProfile[TUPlayerGameProfile.kGameName]    = selectedGame.rawValue
        playerGameProfile[TUPlayerGameProfile.kGameRank]    = playerGameRank
        playerGameProfile[TUPlayerGameProfile.kGameID]      = gameID

        return playerGameProfile
    }

    private func createPlayerRecord() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]   = playerFirstName
        playerRecord[TUPlayer.kLastName]    = playerLastName
        
        return playerRecord
    }

    private func isValidPlayer() -> Bool{
        guard !playerFirstName.isEmpty && !playerLastName.isEmpty else {
            return false
        }
        return true
    }
    
    func createProfile(){
        guard isValidPlayer() else {
            //Invalid Profiles
            alertItem = AlertContext.invalidPlayer
            return
        }
        //Create CKRecord from profile view
        let profileRecord = createPlayerRecord()
        
        guard let userRecord = CloudKitManager.shared.userRecord else {
            //unable to get user record
            alertItem = AlertContext.unableToGetPlayerProfiles
            return
        }

        //Create reference on UserRecord to DDGProfile we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
        
        Task {
            do {
                let records = try await CloudKitManager.shared.batchSave(records: [userRecord,profileRecord])
                for record in records where record.recordType == RecordType.player {
                    existingProfileRecord = record
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
                existingProfileRecord = record
                let profile = TUPlayer(record: record)
                playerFirstName   = profile.firstName
                playerLastName    = profile.lastName

                getGameProfiles()
            } catch {
                //Unable to get player profiles
                alertItem = AlertContext.unableToGetPlayerList
            }
        }
    }
    
    private func getGameProfiles(){
        Task{
            do {
                playerProfiles = try await CloudKitManager.shared.getPlayerGameProfiles()
            } catch {
                //Unable to get player game profiles
                alertItem = AlertContext.unableToGetPlayerList
            }
        }
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
                guard let playerProfileID = CloudKitManager.shared.profileRecordID else {
                    return
                    //Alert
                }
                let playerGameProfile = createPlayerGameProfile()
                playerGameProfile[TUPlayerGameProfile.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerProfileID, action: .deleteSelf)
                let _ = try await CloudKitManager.shared.save(record: playerGameProfile)

                let newPlayerProfile = TUPlayerGameProfile(record: playerGameProfile)

                eventsManager.playerProfiles[playerProfileID]?.append(newPlayerProfile)
                playerProfiles.sort(by: {$0.gameName < $1.gameName})
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
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

                playerProfiles.removeAll(where: {$0.id == gameProfileRecordID})
                eventsManager.playerProfiles[playerProfileID]?.removeAll(where: {$0.id == gameProfileRecordID})
            } catch {
                alertItem = AlertContext.unableToDeleteGameProfile
                isShowingAlert = true
            }
        }
    }
}
