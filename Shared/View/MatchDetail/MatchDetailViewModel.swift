//
//  MatchDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/15/22.
//

import CloudKit
import SwiftUI

@MainActor final class MatchDetailViewModel: ObservableObject {

    var match: TUMatch
    var event: TUEvent
    var playersInEvent: [TUPlayer]

    @Published var teams: [TUTeam]                  = []
    @Published var teamsAndPlayer: [CKRecord.ID: [TUPlayer]] = [:]
    
    @Published var availablePlayers: [TUPlayer]     = []
    @Published var checkedOffPlayers: [TUPlayer]    = []

    @Published var isShowingAddPlayer   = false
    @Published var isShowingAddTeam     = false
    @Published var teamName             = ""

    @Published var isShowingAlert: Bool = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    init(match: TUMatch, playersInEvent: [TUPlayer], event: TUEvent){
        self.match = match
        self.playersInEvent = playersInEvent
        self.event = event
    }

    func resetInput(){
        teamName = ""
    }
    
    private func isValidTeam() -> Bool{
        guard !teamName.isEmpty else {
            return false
        }
        return true
    }

    private func createTeamRecord() -> CKRecord {
        let record = CKRecord(recordType: RecordType.team)
        record[TUTeam.kTeamName] = teamName
        record[TUTeam.kAssociatedToMatch] = CKRecord.Reference(recordID: match.id, action: .deleteSelf)
        record[TUTeam.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)
        
        return record
    }

    func createAndSaveTeam() {
        guard isValidTeam() else {
            alertItem = AlertContext.invalidTeam
            isShowingAlert = true
            return
        }

        Task {
            do {
                let teamRecord = createTeamRecord()
                let _ = try await CloudKitManager.shared.save(record: teamRecord)

                //Reloads view, locally adds player until another network call is made
                teams.append(TUTeam(record: teamRecord))
            } catch {
                alertItem = AlertContext.unableToCreateTeam
                isShowingAlert = true
            }
        }
    }

    func addCheckedPlayersToTeam(with teamID: CKRecord.ID){
        Task {
            do {
                for player in checkedOffPlayers {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []

                    if references.isEmpty{
                        playerRecord[TUPlayer.kOnTeams] = [CKRecord.Reference(recordID: teamID, action: .none)]
                    } else {
                        references.append(CKRecord.Reference(recordID: teamID, action: .none))
                        playerRecord[TUPlayer.kOnTeams] = references
                    }
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                }
            } catch {
                //Could check players in event

                isShowingAlert = true
            }
        }
    }

    func getTeamsForMatch(){
        Task {
            do {
                teams = try await CloudKitManager.shared.getTeamsForMatch(for: match.id)
                for team in teams {
                    let playersInTeam =  try await CloudKitManager.shared.getEventPlayersForTeams(for: team.id)
                    teamsAndPlayer[team.id] = playersInTeam
                }
            } catch {
                alertItem = AlertContext.unableToGetTeamsForMatch
                isShowingAlert = true
            }
        }
    }

    func deletePlayerReferenceToTeam(indexSet: IndexSet, teamID: CKRecord.ID){
        for index in indexSet {
            Task {
                do {
                    guard let player = teamsAndPlayer[teamID]?[index] else {
                        //Alert could not find player to delete
                        return
                    }
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == teamID})
                    
                    playerRecord[TUPlayer.kOnTeams] = references
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                    teamsAndPlayer[teamID]?.remove(at: index)
                } catch{
                    //Unable to get players
                    alertItem = AlertContext.unableToGetMatchesForEvent
                    isShowingAlert = true
                }
            }
        }
    }
    
    private func removeTeamReferenceFromPlayerOnDelete(for teamID: CKRecord.ID){
        Task {
            do {
                for player in teamsAndPlayer[teamID] ?? []{
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == teamID})
                    
                    playerRecord[TUPlayer.kOnTeams] = references
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                }
            } catch {
                //unable to remove team reference from player
            }
        }
    }

    func deleteTeam(teamID: CKRecord.ID){
        Task {
            do {
                removeTeamReferenceFromPlayerOnDelete(for: teamID)
                let _ = try await CloudKitManager.shared.remove(recordID: teamID)

                //Reloads view, locally adds player until another network call is made
                teams.removeAll(where: {$0.id == teamID})
            } catch {
                alertItem = AlertContext.unableToDeleteTeam
                isShowingAlert = true
            }
        }
    }
}
