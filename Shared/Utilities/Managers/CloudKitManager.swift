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
    
}
