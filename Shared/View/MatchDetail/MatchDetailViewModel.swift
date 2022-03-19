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

    @Published var teams: [TUTeam]                           = []
    @Published var teamsAndPlayer: [CKRecord.ID: [TUPlayer]] = [:]

    @Published var availablePlayers: [TUPlayer]     = []
    @Published var checkedOffPlayers: [TUPlayer]    = []

    @Published var isShowingAddPlayer   = false
    @Published var isShowingAddTeam     = false
    @Published var teamName             = ""

    @Published var isLoading: Bool      = false
    @Published var isShowingAlert: Bool = false

    @Published var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    init(match: TUMatch, event: TUEvent){
        self.match = match
        self.event = event
    }

    func isEventOwner() -> Bool{
        return event.eventOwner.recordID == CloudKitManager.shared.userRecord?.recordID
    }

    func isAbleToChangeTeams() -> Bool {
        return teams.count == 2 && isEventOwner()
    }

    func isAbleToAddTeam() -> Bool {
        return teams.count < 2 && isEventOwner()
    }

    func getAvailablePlayers(eventDetailManager: EventDetailManager){

        checkedOffPlayers = []
        availablePlayers = []

        for player in eventDetailManager.playersInEvent {
            if !teamsAndPlayer.values.contains(where: {$0.contains(where: {$0.id == player.id})}) && !availablePlayers.contains(where: {$0.id == player.id}) {
                availablePlayers.append(player)
            }
        }
    }

    func shufflePlayers(){
        var allPlayers: [TUPlayer] = []
        for teams in teamsAndPlayer {
            allPlayers += teams.value
        }

        allPlayers.shuffle()

        let midpoint = allPlayers.count / 2

        let newTeamOne = Array(allPlayers[..<midpoint])
        let newTeamTwo = Array(allPlayers[midpoint...])

        let teamOneRecordID = teams[0].id
        let teamTwoRecordID = teams[1].id

        showLoadingView()
        Task {
            do {
                let teamOneRecord  = try await CloudKitManager.shared.fetchRecord(with: teamOneRecordID)
                let teamTwoRecord  = try await CloudKitManager.shared.fetchRecord(with: teamTwoRecordID)

                var playersToSave: [CKRecord] = []

                for player in newTeamOne + newTeamTwo {
                    //Fetch
                    let playerRecord   = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    var playerOnTeams = playerRecord[TUPlayer.kOnTeams]  as? [CKRecord.Reference] ?? []
                    
                    //Update
                    if playerOnTeams.contains(where: {$0.recordID == teams[1].id}) && newTeamOne.contains(where: {$0.id == player.id}){
                        
                        playerOnTeams.removeAll(where: {$0.recordID == teams[1].id})
                        playerOnTeams.append(CKRecord.Reference(record: teamOneRecord, action: .none))
                        
                    } else if playerOnTeams.contains(where: {$0.recordID == teams[0].id}) && newTeamTwo.contains(where: {$0.id == player.id}){
                        
                        playerOnTeams.removeAll(where: {$0.recordID == teams[0].id})
                        playerOnTeams.append(CKRecord.Reference(record: teamTwoRecord, action: .none))

                    }

                    playerRecord[TUPlayer.kOnTeams] = playerOnTeams
                    
                    playersToSave.append(playerRecord)
                }
                //Save
                let _ = try await CloudKitManager.shared.batchSave(records: playersToSave)
                
                //Update locally and sort by first name
                teamsAndPlayer.updateValue(newTeamOne.sorted(by: {$0.firstName < $1.firstName}), forKey: teams[0].id)
                teamsAndPlayer.updateValue(newTeamTwo.sorted(by: {$0.firstName < $1.firstName}), forKey: teams[1].id)
                hideLoadingView()
            } catch {
                hideLoadingView()
                alertItem = AlertContext.unableToShuffleTeams
                isShowingAlert = true
            }

        }
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
                teamsAndPlayer[teamRecord.recordID] = []
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
                    teamsAndPlayer[teamID]?.append(TUPlayer(record: playerRecord))
                }
            } catch {
                alertItem = AlertContext.unableToAddSelectedPlayersToTeam
                isShowingAlert = true
            }
        }
    }

    func getTeamsForMatch(){
        Task {
            do {
                teams = try await CloudKitManager.shared.getTeamsForMatch(for: match.id)
                for team in teams {
                    let playersInTeam =  try await CloudKitManager.shared.getEventPlayersForTeams(teamID: team.id)
                    teamsAndPlayer[team.id] = playersInTeam
                }
            } catch {
                alertItem = AlertContext.unableToGetTeamsForMatch
                isShowingAlert = true
            }
        }
    }

    func removePlayerFromTeam(player: TUPlayer, teamRecordID: CKRecord.ID){
        Task {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                
                var references = playerRecord[TUPlayer.kOnTeams] as! [CKRecord.Reference]
                references.removeAll(where: {$0.recordID == teamRecordID})
                
                playerRecord[TUPlayer.kOnTeams] = references
                
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                teamsAndPlayer[teamRecordID]?.removeAll(where: {$0.id == player.id})
            } catch{
                alertItem = AlertContext.unableToRemovePlayerFromTeam
                isShowingAlert = true
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
                alertItem = AlertContext.unableToRemovePlayerFromTeam
                isShowingAlert = true
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
                teamsAndPlayer.removeValue(forKey: teamID)
            } catch {
                alertItem = AlertContext.unableToDeleteTeam
                isShowingAlert = true
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
                alertItem = AlertContext.unableToRemovePlayerFromTeam
                isShowingAlert = true
            }
        }
    }

    func deleteMatch(){
        Task {
            do {
                removePlayersFromMatchTeam(matchID: match.id)
                let _ = try await CloudKitManager.shared.remove(recordID: match.id)
                //Teams get deleted by deleteSelf

            } catch {
                alertItem = AlertContext.unableToDeleteMatch
                isShowingAlert = true
            }
        }
    }

    private func showLoadingView(){
        isLoading = true
    }

    private func hideLoadingView(){
        isLoading = false
    }
}
