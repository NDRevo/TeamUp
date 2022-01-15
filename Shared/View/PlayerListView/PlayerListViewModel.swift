//
//  PlayerListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit


@MainActor final class PlayerListViewModel: ObservableObject {
    
    @Published var isShowingAddPlayerSheet  = false
    
    @Published var playerFirstName: String  = ""
    @Published var playerLastName: String   = ""
    @Published var game: Games              = .VALORANT
    @Published var gameID: String           = ""
    @Published var playerGameRank: String   = ""
    
    private func createPlayer() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]   = playerFirstName
        playerRecord[TUPlayer.kLastName]    = playerLastName
        
        return playerRecord
    }
    
    private func createPlayerGameDetails() -> CKRecord {
        let playerGameDetails = CKRecord(recordType: RecordType.playerGameDetails)
        playerGameDetails[TUPlayerGameDetails.kGameName]    = game.rawValue
        playerGameDetails[TUPlayerGameDetails.kGameRank]    = playerGameRank
        playerGameDetails[TUPlayerGameDetails.kGameID]      = gameID

        return playerGameDetails
    }
    
    func createAndSavePlayer(){
        let playerRecord = createPlayer()
        let playerGameDetails = createPlayerGameDetails()
        
        playerGameDetails[TUPlayerGameDetails.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerRecord.recordID, action: .deleteSelf)
        
        Task{
            do {
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
                let _ = try await CloudKitManager.shared.save(record: playerGameDetails)
            } catch {
                //Alert couldnt save
            }
        }
    }
    
    func removePlayer(recordID: CKRecord.ID){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)
            } catch {
                //Alert couldnt remove player
            }
        }
    }
    
    func getPlayers(for eventsManager: EventsManager){
        Task {
            do {
                let _ = try await CloudKitManager.shared.getPlayers()
            } catch {
                //Alert: couldnt get players lsit
            }
        }
    }
}
