//
//  MockData.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

struct MockData {

    static var event: CKRecord {
        let event = CKRecord(recordType: RecordType.event)
        event[TUEvent.kEventName]      = ""
        event[TUEvent.kEventDate]      = Date()
        event[TUEvent.kEventGame]      = "Overwatch"
        event[TUEvent.kEventLocation]  = "BSC 122A"
    
        return event
    }

    static var match: CKRecord {
        let match = CKRecord(recordType: RecordType.match)
        match[TUMatch.kMatchName] = "Immortal"
        match[TUMatch.kStartTime] = Date()
        
        return match
    }
    
    static var team: CKRecord {
        let team = CKRecord(recordType: RecordType.team)
        team[TUTeam.kTeamName] = "Team One"
        
        return match
    }
}
