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
        print("1️⃣ Getting Players")
        
        let sortDescriptor = NSSortDescriptor(key: TUPlayer.kFirstName, ascending: true)
        let query = CKQuery(recordType: RecordType.player, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        print("2️⃣ Got something")
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        print("3️⃣ Match Results: \(matchResults)")
        let records = matchResults.compactMap{_, result in try? result.get()}

        return records.map(TUPlayer.init)
    }
    
    func save(record: CKRecord) async throws -> CKRecord {
        return try await container.publicCloudDatabase.save(record)
    }
}
