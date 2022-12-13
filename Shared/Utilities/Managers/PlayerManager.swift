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

    @AppStorage("isClubLeader") var isClubLeader: ClubLeaderStatus = .notClubLeader
    @AppStorage("studentVerifiedStatus") var studentVerifiedStatus: SchoolVerifiedStatus = .notVerified {
        didSet {
            Task { await saveVerifiedStatus() }
        }
    }

    //iCloudRecord has Published wrapper so it updates Profile view after call to fetch record
    @Published var iCloudRecord: CKRecord?
    @Published var playerProfile: TUPlayer?
    @Published var playerGameProfiles: [TUPlayerGameProfile] = []
    @Published var eventsParticipating: [TUEvent] = []

    //MARK: Creating Profile
    @Published var createdPlayerUsername: String = ""
    @Published var createdPlayerSchool: String = SchoolLibrary.none.rawValue
    @Published var createdPlayerFirstName: String = ""
    @Published var createdPlayerLastName: String = ""

    //MARK: Editing Profile
    @Published var isEditingProfile: Bool = false {
        didSet {
            editedUsername = ""
            editedFirstName = ""
            editedLastName = ""
            editedSelectedSchool = playerProfile!.inSchool
        }
    }
    @Published var editedUsername: String = ""
    @Published var editedFirstName: String = ""
    @Published var editedLastName: String = ""
    @Published var editedSelectedSchool: String = SchoolLibrary.none.rawValue
    @Published var editedSelectedColor: Color? = nil
    @Published var selectedColor: Color? = nil

    @Published var tappedGameProfile: TUPlayerGameProfile?

    @Published var gameID: String                = ""
    @Published var selectedGame: Game            = GameLibrary.data.games[1]
    @Published var selectedGameVariant: Game? {
        didSet {
            if let gameVariant = selectedGameVariant {
                selectedGameRank = gameVariant.getRanksForGame().first
            } else {
                selectedGameRank = nil
            }
        }
    }
    @Published var selectedGameRank: Rank?

    @Published var isEditingGameProfile          = false
    @Published var isPresentingSheet             = false
    @Published var isShowingAddGameProfileAlert  = false
    @Published var isShowingAlert                = false
    @Published var isShowingColorPicker          = false
    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    @Environment(\.dismiss) var dismiss

    var profileColor: Color? {
        return (editedSelectedColor != nil) ? editedSelectedColor! : playerProfile!.profileColor
    }

    init(iCloudRecord:CKRecord? = nil, playerProfile: TUPlayer? = nil) {
        self.iCloudRecord = iCloudRecord
        self.playerProfile = playerProfile
    }

    func resetGameProfileSelections(for game: Game){
        let gameRanks = game.getRanksForGame()
        if !gameRanks.isEmpty {
            selectedGameRank = gameRanks[0]
        } else {
            selectedGameRank = nil
        }
        selectedGameVariant = game.gameVariants.first ?? nil
    }

    func resetGameProfileInput(){
        gameID              = ""
        selectedGame        = GameLibrary.data.games[1]
        selectedGameVariant = nil
        selectedGameRank    = nil
    }

    func resetCreateProfileInput(){
        createdPlayerUsername = ""
        createdPlayerSchool = SchoolLibrary.none.rawValue
        createdPlayerFirstName = ""
        createdPlayerLastName = ""
    }

    private func isValidGameProfile() -> Bool {
        guard !gameID.isEmpty else { return false }
        return true
    }

    private func isValidUsername(username: String) -> Bool {
        if username.isEmpty {return false}

        let usernameRegex = "([A-Za-z0-9])\\w+"
        let isValidUsernameString   =  NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username)

        if !isValidUsernameString {
            alertItem = AlertContext.invalidUsername
            return false
        }
        return true
    }

    private func isValidName(name: String) -> Bool {
        if name.isEmpty {return false}

        let nameRegex = "([A-Za-z])\\w+"
        let isValidNameString  =  NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)

        if !isValidNameString {
            alertItem = AlertContext.invalidName
            return false
        }
        return true
    }

    private func isValidCreatedPlayer() async throws -> Bool {

        if !isValidUsername(username: self.createdPlayerUsername) {
            return false
        } else {
            let userExists = try await CloudKitManager.shared.checkUsernameExists(for: createdPlayerUsername)
            if userExists {
                return false
            }
        }

        if !isValidName(name: self.createdPlayerFirstName) || !isValidName(name: self.createdPlayerLastName) {
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
        playerGameProfile[TUPlayerGameProfile.kGameAliases]     = nil

        return playerGameProfile
    }

    private func createPlayerRecord() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kUsername]         = createdPlayerUsername
        playerRecord[TUPlayer.kInSchool]         = createdPlayerSchool
        playerRecord[TUPlayer.kFirstName]        = createdPlayerFirstName
        playerRecord[TUPlayer.kLastName]         = createdPlayerLastName
        playerRecord[TUPlayer.kIsClubLeader]     = ClubLeaderStatus.notClubLeader.rawValue
        playerRecord[TUPlayer.kIsVerfiedStudent] = 0

        return playerRecord
    }

    func createProfile() async {
        do {
            guard try await isValidCreatedPlayer() else {
                isShowingAlert = true
                return
            }
        } catch {
            //Will hit if can't search name in CloudKit
            alertItem = AlertContext.unableToCheckIfValidPlayer
            isShowingAlert = true
        }

        //Creates CKRecord from profile view
        let playerRecord = createPlayerRecord()

        guard let userRecord = iCloudRecord else {
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
                resetCreateProfileInput()
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
                guard let record = playerProfile else { return }

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

                eventsParticipating = mappedRecords.map(TUEvent.init).sorted(by: {$0.eventStartDate < $1.eventStartDate}).filter({$0.isArchived == 0})
            } catch {
                alertItem = AlertContext.unableToFetchEventsParticipating
                isShowingAlert = true
            }
        }
    }

    nonisolated func saveEditGameProfile(of gameProfile: TUPlayerGameProfile, gameID: String, gameRank: String, gameAliases: [String]) async {
        do {
            let gameProfileRecord = try await CloudKitManager.shared.fetchRecord(with: gameProfile.id)

            gameProfileRecord[TUPlayerGameProfile.kGameID] = gameID
            gameProfileRecord[TUPlayerGameProfile.kGameRank] = gameRank
            
            if gameAliases.allSatisfy({ aliases in
                aliases.isEmpty || aliases.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }) {
                gameProfileRecord[TUPlayerGameProfile.kGameAliases] = nil
            } else {
                gameProfileRecord[TUPlayerGameProfile.kGameAliases] = gameAliases
            }
        

            let newGameProfileRecord = try await CloudKitManager.shared.save(record: gameProfileRecord)
            await MainActor.run {
                playerGameProfiles.removeAll(where: {$0.id == gameProfile.id})
                playerGameProfiles.append(TUPlayerGameProfile(record: newGameProfileRecord))
                playerGameProfiles.sort(by: {$0.gameName < $1.gameName})
                isEditingGameProfile = false
            }
        } catch {
            await MainActor.run {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAlert = true
            }
        }
    }

    nonisolated func saveVerifiedStatus() async {
        do {
            if (await playerProfile) != nil {
                //Need to fetch most recent record or else error: 'client oplock error updating record' will happen
                let playerProfileRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfile!.id)
                playerProfileRecord[TUPlayer.kIsVerfiedStudent] = await studentVerifiedStatus.rawValue

                let newPlayerRecord = try await CloudKitManager.shared.save(record: playerProfileRecord)

                await MainActor.run {
                    self.playerProfile = TUPlayer(record: newPlayerRecord)
                }
            }
        } catch {
            await MainActor.run {
                alertItem = AlertContext.unableToSaveVerifiedStatus
                isShowingAlert = true
            }
        }
    }

    func saveEditedProfile() async {
        await MainActor.run {
            if editedUsername.isEmpty && editedFirstName.isEmpty && editedLastName.isEmpty && editedSelectedSchool == playerProfile!.inSchool  {
                withAnimation {
                    isEditingProfile = false
                }
                return
            }
        }

        let isValidUsername = isValidUsername(username: editedUsername)
        let isValidFirstName = isValidName(name: editedFirstName )
        let isValidLastName  = isValidName(name: editedLastName )
        
        do {
            //Need to fetch most recent record or else error: 'client oplock error updating record' will happen
            let playerProfileRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfile!.id)
            let usernameExists = try await CloudKitManager.shared.checkUsernameExists(for: editedUsername)

            if !editedUsername.isEmpty {
                if usernameExists && playerProfile?.username == editedUsername {/* Don't do anything */}
                else if usernameExists && playerProfile?.username != editedUsername {
                    alertItem = AlertContext.invalidUsername
                    isShowingAlert = true
                    return
                } else if isValidUsername && !usernameExists {
                    playerProfileRecord[TUPlayer.kUsername] = editedUsername
                }
            }
            if !editedFirstName.isEmpty {
                if isValidFirstName { playerProfileRecord[TUPlayer.kFirstName] = editedFirstName }
            }
            if !editedLastName.isEmpty {
                if isValidLastName{ playerProfileRecord[TUPlayer.kLastName] = editedLastName }
            }

            playerProfileRecord[TUPlayer.kInSchool] = editedSelectedSchool

            if let editedSelectedColor = editedSelectedColor {
                if playerProfile?.profileColor != Color(hexString: editedSelectedColor.toHexString()!) {
                    playerProfileRecord[TUPlayer.kProfileColor] = editedSelectedColor.toHexString()
                }
            }

            let newPlayerRecord = try await CloudKitManager.shared.save(record: playerProfileRecord)
            playerProfile = TUPlayer(record: newPlayerRecord)

            // Not called in didSet, when tapping on 'dismiss' or 'change' it would have set editedSelectedColor to nil before saving
            editedSelectedColor = nil
            withAnimation{
                isEditingProfile = false
            }
        } catch {
            //Valid checks change the alertItem
            if !isValidUsername || !isValidFirstName || !isValidLastName { isShowingAlert = true }
            else {
                alertItem = AlertContext.unableToSaveEditedProfile
                isShowingAlert = true
            }
        }
    }

    func saveGameProfile(){
        guard isValidGameProfile() else {
            alertItem = AlertContext.invalidGameProfile
            isShowingAddGameProfileAlert = true
            return
        }

        Task{
            do {
                guard let playerProfileID = playerProfile else {
                    alertItem = AlertContext.unableToGetUserProfile
                    isShowingAddGameProfileAlert = true
                    return
                }
                let playerGameProfile = createPlayerGameProfile()
                playerGameProfile[TUPlayerGameProfile.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerProfileID.id, action: .deleteSelf)
                let newPlayerGameProfileRecord = try await CloudKitManager.shared.save(record: playerGameProfile)
                let newPlayerProfile = TUPlayerGameProfile(record: newPlayerGameProfileRecord)

                playerGameProfiles.append(newPlayerProfile)
                playerGameProfiles.sort(by: {$0.gameName < $1.gameName})
                isPresentingSheet = false
            } catch {
                alertItem = AlertContext.unableToSaveGameProfile
                isShowingAddGameProfileAlert = true
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

    /// Retrieves user record from iCloud
    /// Fetches user record from CloudKit
    /// Fetches TUPlayer record using user record
    /// Fetches game profiles
    func getRecordAndPlayerProfile() async {
        Task{
            do {
                let recordID = try await CloudKitManager.shared.container.userRecordID()
                iCloudRecord = try await CloudKitManager.shared.container.publicCloudDatabase.record(for: recordID)

                if let profileReference = iCloudRecord!["userProfile"] as? CKRecord.Reference {
                    let playerProfileRecord = try await CloudKitManager.shared.fetchRecord(with: profileReference.recordID)
                    playerProfile = TUPlayer(record: playerProfileRecord)

                    if let playerProfile = playerProfile {
                        switch playerProfile.isClubLeader {
                        case 0: isClubLeader = .notClubLeader
                        case 1: isClubLeader = .clubLeader
                        case 2: isClubLeader = .requestClubLeader
                        case 3: isClubLeader = .deniedClubLeader
                        default:
                            isClubLeader = .notClubLeader
                        }
                    }
                    getGameProfiles()
                    getEventsParticipating()
                } else {
                    playerProfile = nil
                    isClubLeader = .notClubLeader
                    studentVerifiedStatus = .notVerified
                }
            } catch {
                //Player Profile tab already displays the need to log into iCloud
                if iCloudRecord == nil {}
                else {
                    alertItem = AlertContext.unableToGetUserRecord
                    isShowingAlert = true
                }
            }
        }
    }

    /// Retrieves game profiles for player
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
