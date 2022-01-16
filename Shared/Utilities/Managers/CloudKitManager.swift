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

    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?

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
    
    func getTeams(for matchID: CKRecord.ID) async throws -> [TUTeam]{
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
}
