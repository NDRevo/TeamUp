//
//  CloudKitManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit

//MARK: CloudKitManager
//INFO: Singleton handling all things CloudKit related
final class CloudKitManager {

    static let shared = CloudKitManager()

    var userRecord: CKRecord?
    var playerProfile: TUPlayer?
    let container = CKContainer.default()

    func checkUsernameExists(for username: String) async throws -> Bool {
        let predicate = NSPredicate(format: "userName == %@", username)
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        
        let (results, _) = try await container.publicCloudDatabase.records(matching: query)
        if !results.isEmpty {
            return true
        } else {
            return false
        }
    }

    func getUserRecord() async throws -> TUPlayer? {
        let recordID = try await container.userRecordID()
        let record = try await container.publicCloudDatabase.record(for: recordID)
        userRecord = record

        if let profileReference = record["userProfile"] as? CKRecord.Reference {
            let playerProfileRecord = try await fetchRecord(with: profileReference.recordID)
            playerProfile = TUPlayer(record: playerProfileRecord)
            return playerProfile
       }
        return nil
    }
    
    func fetchUserRecord() async throws {
        let recordID = try await container.userRecordID()
        let record = try await container.publicCloudDatabase.record(for: recordID)
        userRecord = record

        if let profileReference = record["userProfile"] as? CKRecord.Reference {
            let playerProfileRecord = try await fetchRecord(with: profileReference.recordID)
            playerProfile = TUPlayer(record: playerProfileRecord)
       }
    }

    func getPlayers() async throws -> [TUPlayer] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
        let query = CKQuery(recordType: RecordType.player, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        return records.map(TUPlayer.init)
    }

    func getPlayers(with searchString: String) async throws -> [TUPlayer] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
       
        let firstNamePredicate  = NSPredicate(format: "firstName BEGINSWITH %@", searchString)
        let lastNamePredicate   = NSPredicate(format: "lastName BEGINSWITH %@", searchString)

        //let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePredicate,])
        let firstNameQuery = CKQuery(recordType: RecordType.player, predicate: firstNamePredicate)
        firstNameQuery.sortDescriptors = [sortDescriptor]
        
        let lastNameQuery = CKQuery(recordType: RecordType.player, predicate: lastNamePredicate)
        lastNameQuery.sortDescriptors = [sortDescriptor]

        let (firstNameResults, _) = try await container.publicCloudDatabase.records(matching: firstNameQuery)
        let (lastNameResults, _) = try await container.publicCloudDatabase.records(matching: lastNameQuery)
        
        let totalResults = firstNameResults + lastNameResults
        
        let records = totalResults.compactMap{_, result in try? result.get()}
        
        let newRecords = records.map(TUPlayer.init)
        
        //DUPLICATES
        return newRecords
    }

    func getPlayersAndProfiles() async throws -> [CKRecord.ID: [TUPlayerGameProfile]] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayerGameProfile.kGameName, ascending: true)
        let query = CKQuery(recordType: RecordType.playerGameProfiles, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        var playersAndProfiles: [CKRecord.ID: [TUPlayerGameProfile]] = [:]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
        
        for record in records {
            let playerGameProfiles = TUPlayerGameProfile(record: record)

            guard let playerReference = record[TUPlayerGameProfile.kAssociatedToPlayer] as? CKRecord.Reference else { continue }
            playersAndProfiles[playerReference.recordID, default: []].append(playerGameProfiles)
        }

        return playersAndProfiles
    }

    func getPlayerGameProfiles() async throws -> [TUPlayerGameProfile] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayerGameProfile.kGameName, ascending: true)
        
        guard let profileRecordID = playerProfile else {
            return []
        }
        let reference = CKRecord.Reference(recordID: profileRecordID.id, action: .none)
        let predicate = NSPredicate(format: "associatedToPlayer == %@", reference)
        let query = CKQuery(recordType: RecordType.playerGameProfiles, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}

        return records.map(TUPlayerGameProfile.init)
    }
    
    func getGamesForPlayer(for playerID: CKRecord.ID) async throws -> [TUPlayerGameProfile] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayerGameProfile.kGameName, ascending: true)
       
        let reference = CKRecord.Reference(recordID: playerID, action: .none)
        let predicate = NSPredicate(format: "associatedToPlayer == %@", reference)
        
        let query = CKQuery(recordType: RecordType.playerGameProfiles, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
    
        return records.map(TUPlayerGameProfile.init)
    }

    func getPlayersForEvent(for eventID: CKRecord.ID) async throws -> [TUPlayer] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
        //Get Reference
        let reference = CKRecord.Reference(recordID: eventID, action: .none)
        let predicate = NSPredicate(format: "inEvents CONTAINS %@", reference)

        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
        
        return records.map(TUPlayer.init)
    }

    func getPlayerRecordsForEvent(for eventID: CKRecord.ID) async throws -> [CKRecord] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
        //Get Reference
        let reference = CKRecord.Reference(recordID: eventID, action: .none)
        let predicate = NSPredicate(format: "inEvents CONTAINS %@", reference)

        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
        
        return records
    }

    func getEventPlayersForTeams(teamID: CKRecord.ID) async throws -> [TUPlayer]  {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)

        let teamReference = CKRecord.Reference(recordID: teamID, action: .none)
        let predicate = NSPredicate(format: "onTeams CONTAINS %@", teamReference)
        
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}

        return records.map(TUPlayer.init)
    }
    
    func getEventPlayersRecordForTeams(teamID: CKRecord.ID) async throws -> [CKRecord]  {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)

        let teamReference = CKRecord.Reference(recordID: teamID, action: .none)
        let predicate = NSPredicate(format: "onTeams CONTAINS %@", teamReference)
        
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}

        return records
    }

    func getEvents(thatArePublished: Bool, withSpecificOwner: Bool, forGame: Game = Game(name: GameNames.all, ranks: [])) async throws -> [TUEvent] {
        let sortDescriptor = NSSortDescriptor(key: TUEvent.kEventStartDate, ascending: true)
        let publishPredicate   = thatArePublished ? NSPredicate(format: "isPublished == 1") : NSPredicate(format: "isPublished == 0")
        let eventGamePredicate = NSPredicate(format: "eventGameName == %@", forGame.name)

        var predicate = NSPredicate()

        if forGame.name == GameNames.all {
            predicate = publishPredicate
        } else {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [publishPredicate, eventGamePredicate])
        }

        let query = CKQuery(recordType: RecordType.event, predicate: predicate)

        query.sortDescriptors = [sortDescriptor]

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        if withSpecificOwner {
            return records.filter{
                //MARK: ERROR - Unexpectedly found nil (Cause: No/Slow internet connection)
                $0[TUEvent.kEventOwner] == CKRecord.Reference(recordID: userRecord!.recordID, action: .none)
            }.map(TUEvent.init)
        }

        return records.map(TUEvent.init)
    }

    func getMatches(for eventID: CKRecord.ID) async throws -> [TUMatch]{
        //Get Reference
        let reference = CKRecord.Reference(recordID: eventID, action: .deleteSelf)
        let predicate = NSPredicate(format: "associatedToEvent == %@", reference)
        
        //Sort by time
        let sortDescriptor = NSSortDescriptor(key: TUMatch.kStartTime, ascending: true)
        let query = CKQuery(recordType: RecordType.match, predicate: predicate)
        
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{ _, result in try? result.get()}
        
        return records.map(TUMatch.init)
    }

    func getTeams() async throws -> [TUTeam] {
        let query = CKQuery(recordType: RecordType.team, predicate: NSPredicate(value: true))
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        return records.map(TUTeam.init)
    }

    func getAllTeamRecordIDs() async throws -> [CKRecord.ID] {
        let query = CKQuery(recordType: RecordType.team, predicate: NSPredicate(value: true))
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        
        return records.map { record in
            return record.recordID
        }
    }

    func getTeamsFromEvent(for eventID: CKRecord.ID) async throws -> [CKRecord] {
        let reference = CKRecord.Reference(recordID: eventID, action: .deleteSelf)
        let predicate = NSPredicate(format: "associatedToEvent == %@", reference)
        
        let query = CKQuery(recordType: RecordType.team, predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        
        return records
    }

    func getTeamsForMatch(for matchID: CKRecord.ID) async throws -> [TUTeam]{
        //Get Reference
        let reference = CKRecord.Reference(recordID: matchID, action: .deleteSelf)
        let predicate = NSPredicate(format: "associatedToMatch == %@", reference)
        
        let sortDescriptor = NSSortDescriptor(key: TUTeam.kCreationDate, ascending: true)
        let query = CKQuery(recordType: RecordType.team, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{ _, result in try? result.get()}
        
        return records.map(TUTeam.init)
    }

    func batchSave(records: [CKRecord]) async throws -> [CKRecord]{
        let (savedResult, _) = try await container.publicCloudDatabase.modifyRecords(saving: records, deleting: [])
        return savedResult.compactMap { _, result in try? result.get() }
    }

    func save(record: CKRecord) async throws -> CKRecord {
        return try await container.publicCloudDatabase.save(record)
    }

    func remove(recordID: CKRecord.ID) async throws -> CKRecord.ID {
       return try await CloudKitManager.shared.container.publicCloudDatabase.deleteRecord(withID: recordID)
    }

    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        return try await container.publicCloudDatabase.record(for: id)
    }

    func fetchRecords(with ids: [CKRecord.ID]) async throws -> [CKRecord.ID : Result<CKRecord, any Error>] {
        return try await container.publicCloudDatabase.records(for: ids)
    }
}
