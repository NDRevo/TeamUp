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
    @Published var game: Games              = .valorant
    @Published var gameID: String           = ""
    @Published var playerGameRank: String   = ""
    
    //HANDLE LATER: Stops app from calling getPlayers() twice in .task modifier: Swift Bug
    @Published var onAppearHasFired = false

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
    
     func resetInput(){
        playerFirstName = ""
        playerLastName  = ""
        game            = .valorant
        gameID          = ""
        playerGameRank  = ""
    }

    func createAndSavePlayer(for eventsManager: EventsManager){
        let playerRecord = createPlayer()
        let playerGameDetails = createPlayerGameDetails()
        
        playerGameDetails[TUPlayerGameDetails.kAssociatedToPlayer] = CKRecord.Reference(recordID: playerRecord.recordID, action: .deleteSelf)
        
        Task{
            do {
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
                let _ = try await CloudKitManager.shared.save(record: playerGameDetails)
                
                //Reloads view, locally adds player until another network call is made
                eventsManager.players.append(TUPlayer(record: playerRecord))
            } catch {
                //Alert couldnt save
            }
        }
    }
    
    func deletePlayer(recordID: CKRecord.ID){
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
                eventsManager.players = try await CloudKitManager.shared.getPlayers()
            } catch {
                //Alert: couldnt get players lsit
            }
        }
    }
}
