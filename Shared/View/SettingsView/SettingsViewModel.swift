//
//  SettingsViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import Foundation
import CloudKit
import SwiftUI

@MainActor class SettingsViewModel: ObservableObject {

    @Published var isShowingWebsite         = false
    @Published var hasVerified: Bool = false {
        didSet {
            Task {
                 await changeVerificationStatus(hasVerified)
            }
        }
    }
    @Published var isShowingAlert           = false

    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    //0 = Not Game Leader
    //1 = Game Leader
    //2 = Requesting Game Leader
    //3 = Denied Game Leader

    nonisolated func changeGameLeaderPosition(to value: Int) async {
            do {
                guard let playerProfileID = CloudKitManager.shared.playerProfile else {
                    await MainActor.run {
                        alertItem = AlertContext.unableToGetUserProfile
                        isShowingAlert = true
                    }
                    return
                }
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfileID.id)
                playerRecord[TUPlayer.kIsGameLeader] = value
                let _ = try await CloudKitManager.shared.save(record: playerRecord)

            } catch {
                await MainActor.run {
                    alertItem = AlertContext.unableToChangeGameLeaderPosition
                    isShowingAlert = true
                }
            }
    }
    
    nonisolated func changeVerificationStatus(_ hasVerified: Bool) async{
            do {
                guard let playerProfileID = CloudKitManager.shared.playerProfile else {
                    await MainActor.run {
                        alertItem = AlertContext.unableToGetUserProfile
                        isShowingAlert = true
                    }
                    return
                }
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerProfileID.id)
                playerRecord[TUPlayer.kIsVerfiedStudent] = hasVerified ? 1 : 0
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
                
            } catch {
                await MainActor.run {
                    //MARK: Add Alert
                    isShowingAlert = true
                }
            }
        
    }
    
}
