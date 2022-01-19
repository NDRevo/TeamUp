//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent

    init(event: TUEvent){
        self.event = event
        matchDate = event.eventDate
    }

    //Players that join/added to the event from the players list
    @Published var playersInEvent: [TUPlayer]   = []
    @Published var matches: [TUMatch]            = []

    @Published var checkedOffPlayers: [TUPlayer] = []
    @Published var availablePlayers: [TUPlayer]  = []

    @Published var matchName: String = ""
    @Published var matchDate: Date = Date()

    @Published var isShowingAddMatch            = false
    @Published var isShowingAddPlayerToEvent    = false
    @Published var isShowingAddAdmin            = false
    
    @Published var isShowingAlert: Bool         = false
    @Published var alertItem: AlertItem         = AlertItem(alertTitle: Text("Unable To Show Alert"),
                                                            alertMessage: Text("There was a problem showing the alert."))
    
    @Environment(\.dismiss) var dismiss

    func resetMatchInput(){
        matchName = ""
        matchDate = event.eventDate
    }

    private func createMatchRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.match)

        record[TUMatch.kMatchName]     = matchName
        record[TUMatch.kStartTime]     = matchDate
        record[TUMatch.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)

        return record
    }

    private func isValidMatch() -> Bool{
        guard !matchName.isEmpty, matchDate >= event.eventDate else {
            return false
        }
        return true
    }
    
    func setUpEventDetail(with players: [TUPlayer]){
        getMatchesForEvent()
        getPlayersInEvents()
        getAvailablePlayers(from: players)
    }

    func createMatchForEvent(){
        guard isValidMatch() else {
            alertItem = AlertContext.invalidMatch
            isShowingAlert = true
            return
        }

        Task{
            do{
                let matchRecord = createMatchRecord()
                let _ = try await CloudKitManager.shared.save(record: matchRecord)

                //Reloads view, locally adds player until another network call is made
                matches.append(TUMatch(record: matchRecord))
            } catch {
                alertItem = AlertContext.unableToCreateMatch
                isShowingAlert = true
            }
        }
    }

    private func getMatchesForEvent(){
        Task {
            do {
                matches = try await CloudKitManager.shared.getMatches(for: event.id)
            } catch{
                alertItem = AlertContext.unableToGetMatchesForEvent
                isShowingAlert = true
            }
        }
    }

    private func getPlayersInEvents(){
        Task {
            do {
                playersInEvent = try await CloudKitManager.shared.getPlayersForEvent(for: event.id)
            } catch{
                //Unable to get players
                alertItem = AlertContext.unableToGetMatchesForEvent
                isShowingAlert = true
            }
        }
    }

    private func getAvailablePlayers(from players: [TUPlayer]){
        Task {
            do{
                availablePlayers = []
                for player in players {
                    let playerRecord    = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    let playerInEvents  = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []
                    if playerInEvents.contains(where: {$0.recordID != event.id}) || playerInEvents.isEmpty{
                        availablePlayers.append(player)
                    }
                }
            } catch {
                alertItem = AlertContext.unableToGetAvailablePlayers
                isShowingAlert = true
            }
        }
    }

    func removePlayerFromEventWith(indexSet: IndexSet){
        for index in indexSet {
            Task {
                do {
                    let player = playersInEvent[index]
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == event.id})
                    
                    playerRecord[TUPlayer.kInEvents] = references
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                    
                    playersInEvent.remove(at: index)
                } catch{
                    //Unable to get players
                    alertItem = AlertContext.unableToGetMatchesForEvent
                    isShowingAlert = true
                }
            }
        }
    }

    func removePlayersFromMatchTeam(matchID: CKRecord.ID){
        Task{
            do {
                let teamsFromDeletedMatch = try await CloudKitManager.shared.getTeamsForMatch(for: matchID)

                for team in teamsFromDeletedMatch{
                    //For players in each team
                    let playerRecordsInTeam = try await CloudKitManager.shared.getEventPlayersRecordForTeams(teamID: team.id)

                    //For player in specific team
                    for playerRecord in playerRecordsInTeam {
                        var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []

                        teamReferences.removeAll(where: {$0.recordID == team.id})
                        playerRecord[TUPlayer.kOnTeams] = teamReferences
                        let _ = try await CloudKitManager.shared.save(record: playerRecord)
                    }
                }
            } catch {
                alertItem = AlertContext.unableToDeleteMatch
                isShowingAlert = true
            }
        }
    }

    func deleteMatch(matchID: CKRecord.ID){
        Task {
            do {
                removePlayersFromMatchTeam(matchID: matchID)
                let _ = try await CloudKitManager.shared.remove(recordID: matchID)

                //Reloads view, locally adds player until another network call is made
                matches.removeAll(where: {$0.id == matchID})
            } catch {
                alertItem = AlertContext.unableToDeleteMatch
                isShowingAlert = true
            }
        }
    }

    func addCheckedPlayersToEvent(){
        Task {
            do {
                for player in checkedOffPlayers {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                    if references.isEmpty{
                        playerRecord[TUPlayer.kInEvents] = [CKRecord.Reference(recordID: event.id, action: .none)]
                    } else {
                        references.append(CKRecord.Reference(recordID: event.id, action: .none))
                        playerRecord[TUPlayer.kInEvents] = references
                    }
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                }
            } catch {
                //Could check players in event
                alertItem = AlertContext.unableToDeleteMatch
                isShowingAlert = true
            }
        }
    }

    func dateRange() -> PartialRangeFrom<Date> {
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: event.eventDate),
            month: calendar.component(.month, from: event.eventDate),
            day: calendar.component(.day, from: event.eventDate)
        )
        return calendar.date(from:startDate)!...
    }
}
