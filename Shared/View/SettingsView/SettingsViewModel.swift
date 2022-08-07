//
//  SettingsViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import Foundation
import CloudKit
import SwiftUI

class SettingsViewModel: ObservableObject {

    @Published var isShowingAlert            = false

    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    //0 = Not Game Leader
    //1 = Game Leader
    //2 = Requesting Game Leader
    //3 = Denied Game Leader

    func changeGameLeaderPosition(to value: Int){
        Task{
            do {
                guard let playerProfileID = CloudKitManager.shared.playerProfile else {
                    alertItem = AlertContext.unableToGetUserProfile
                    isShowingAlert = true
                    return
                }
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfileID.id)
                playerRecord[TUPlayer.kIsGameLeader] = value
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

            } catch {
                alertItem = AlertContext.unableToChangeGameLeaderPosition
                isShowingAlert = true
            }
        }
    }
}
