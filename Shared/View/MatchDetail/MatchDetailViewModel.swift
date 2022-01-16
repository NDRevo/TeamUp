//
//  MatchDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/15/22.
//

import CloudKit

@MainActor final class MatchDetailViewModel: ObservableObject {
    
    var match: TUMatch
    
    @Published var teams: [TUTeam]      = []
    @Published var isShowingAddPlayer   = false
    @Published var isShowingAddTeam     = false
    @Published var teamName             = ""
    
    init(match: TUMatch){
        self.match = match
    }
    
    func getTeamsForMatch(){
        Task {
            do {
                teams = try await CloudKitManager.shared.getTeams(for: match.id)
            } catch {
                print("❌ \(error)")
                //Alert: Could not get teams
            }
        }
    }
    
    private func createTeamRecord() -> CKRecord {
        let record = CKRecord(recordType: RecordType.team)
        record[TUTeam.kTeamName] = teamName
        record[TUTeam.kAssociatedToMatch] = CKRecord.Reference(recordID: match.id, action: .deleteSelf)
        
        return record
    }
    
    func createAndSaveTeam() {
        Task {
            do {
                let teamRecord = createTeamRecord()
                let _ = try await CloudKitManager.shared.save(record: teamRecord)
            } catch {
                print("❌ \(error)")
                //Unable to save team
            }
        }
    }
    
    func deleteTeam(recordID: CKRecord.ID){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)
            } catch {
                //Could not delete team
            }
        }
    }
}
