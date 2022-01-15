//
//  PlayerListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit


final class PlayerListViewModel: ObservableObject {
    @Published var playerFirstName: String   = ""
    @Published var playerLastName: String   = ""
    @Published var game: Games          = .VALORANT
    @Published var gameID: String       = ""
    @Published var playerRank: String   = ""
    
    private func createPlayer() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName]   = playerFirstName
        playerRecord[TUPlayer.kLastName]    = playerLastName
        
        return playerRecord
    }
    
    func createAndSavePlayer(){
        let playerRecord = createPlayer()
        Task{
            do {
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
            } catch {
                //Alert
            }
        }
    }
}
