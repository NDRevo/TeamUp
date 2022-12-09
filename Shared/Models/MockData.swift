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
        event[TUEvent.kEventName]      = "In-Houses"
        event[TUEvent.kEventGameName]  = "Overwatch"
        event[TUEvent.kEventStartDate] = Date()
        event[TUEvent.kEventEndDate]  = Date() + 100_000_000
        event[TUEvent.kEventLocation]  = "discord.gg/valowatch"
        event[TUEvent.kEventSchool]  = "Rutgers University"
        event[TUEvent.kEventDescription]  = "This is an event where you can see the description of said event. This event will be hosted on x date with prizes being rewarded for everyone that wins"

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

        return team
    }
    
    static var player: CKRecord {
        let player = CKRecord(recordType: RecordType.player)
        player[TUPlayer.kFirstName]     = "Bob"
        player[TUPlayer.kLastName]      = "Ross"
        player[TUPlayer.kUsername]      = "Revo"
        player[TUPlayer.kInSchool]      = "Rutgers University - New Brunswick"
        player[TUPlayer.kIsClubLeader]  = ClubLeaderStatus.clubLeader.rawValue
        player[TUPlayer.kIsVerfiedStudent]  = 0

        return player
    }
    static var playerGameProfile: CKRecord {
        let playerGameProfile = CKRecord(recordType: RecordType.playerGameProfiles)
        playerGameProfile[TUPlayerGameProfile.kGameName]    = "VALORANT"
        playerGameProfile[TUPlayerGameProfile.kGameID]      = "Bob#ross"
        playerGameProfile[TUPlayerGameProfile.kGameRank]    = "Radiant"
        playerGameProfile[TUPlayerGameProfile.kGameAliases] = ["Revo#0010", "Tenz#NA1"]

        return playerGameProfile
    }
}
