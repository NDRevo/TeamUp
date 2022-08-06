//
//  SettingsViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import Foundation
import CloudKit

class SettingsViewModel: ObservableObject {
    
    //0 = Not Game Leader
    //1 = Game Leader
    //2 = Requesting Game Leader
    //3 = Denied Game Leader

    func changeGameLeaderPosition(to value: Int){
        Task{
            do {
                guard let playerProfileID = CloudKitManager.shared.playerProfile else {
                    return
                    //Alert
                }
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfileID.id)
                playerRecord[TUPlayer.kIsGameLeader] = value
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

            } catch {
                //alertItem = AlertContext.unableToSaveGameProfile
                //isShowingAlert = true
            }
        }
    }
}
