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

    @Published var teams: [TUTeam]      = []
    @Published var isShowingAddPlayer   = false
    @Published var isShowingAddTeam     = false
    @Published var teamName             = ""

    @Published var isShowingAlert: Bool = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    init(match: TUMatch){
        self.match = match
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

    func getTeamsForMatch(){
        Task {
            do {
                teams = try await CloudKitManager.shared.getTeams(for: match.id)
            } catch {
                alertItem = AlertContext.unableToGetTeamsForMatch
                isShowingAlert = true
            }
        }
    }

    func deleteTeam(recordID: CKRecord.ID){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)

                //Reloads view, locally adds player until another network call is made
                teams.removeAll(where: {$0.id == recordID})
            } catch {
                alertItem = AlertContext.unableToDeleteTeam
                isShowingAlert = true
            }
        }
    }
}
