//
//  CloudKitManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit

//Needs to be singleton instead of struct because we need to save user record
//Singleton is like global variable, but can be hard to debug
final class CloudKitManager {

    static let shared = CloudKitManager()

    let container = CKContainer.default()

    private init(){}
    
    
    func getPlayers() async throws -> [TUPlayer] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
        let query = CKQuery(recordType: RecordType.player, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

        return records.map(TUPlayer.init)
    }
    
    func getPlayersAndDetails() async throws -> [CKRecord.ID: [TUPlayerGameDetails]] {
        let sortDescriptor = NSSortDescriptor(key: TUPlayerGameDetails.kGameName, ascending: true)
        let query = CKQuery(recordType: RecordType.playerGameDetails, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        var playersAndDetails: [CKRecord.ID: [TUPlayerGameDetails]] = [:]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
        
        for record in records {
            let playerGameDetails = TUPlayerGameDetails(record: record)

            //Gets location record because isCheckedIn is reference to location
            guard let playerReference = record[TUPlayerGameDetails.kAssociatedToPlayer] as? CKRecord.Reference else { continue }
            playersAndDetails[playerReference.recordID, default: []].append(playerGameDetails)
        }

        return playersAndDetails
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

    func getEventPlayersForTeams(for teamID: CKRecord.ID) async throws -> [TUPlayer]  {
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)

        let teamReference = CKRecord.Reference(recordID: teamID, action: .none)
        let predicate = NSPredicate(format: "onTeams CONTAINS %@", teamReference)
        
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}

        return records.map(TUPlayer.init)
    }
    
    func getEvents() async throws -> [TUEvent] {
        let sortDescriptor = NSSortDescriptor(key: TUEvent.kEventDate, ascending: true)
        let query = CKQuery(recordType: RecordType.event, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap{_, result in try? result.get()}

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

        
        return records    }
    
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
    
    func save(record: CKRecord) async throws -> CKRecord {
        return try await container.publicCloudDatabase.save(record)
    }
    
    func remove(recordID: CKRecord.ID) async throws -> CKRecord.ID {
       return try await CloudKitManager.shared.container.publicCloudDatabase.deleteRecord(withID: recordID)
    }
    
    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        return try await container.publicCloudDatabase.record(for: id)
    }
}
