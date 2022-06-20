//
//  EventsManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventsManager: ObservableObject {

    init(){}

    @Published var userRecord: CKRecord?
    @Published var events: [TUEvent]    = []
    @Published var players: [TUPlayer]  = []

    @Published var myPublishedEvents: [TUEvent] = []
    @Published var myUnpublishedEvents: [TUEvent] = []

    @Published var playerProfiles: [CKRecord.ID:[TUPlayerGameProfile]] = [:]
    @Published var playerCountPerEvent: [CKRecord.ID:Int]              = [:]

    @Published var isShowingAlert            = false
    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    func getRanksForGame(game: Games) -> [String]{
        switch game {
            case .overwatch:    return ["Unranked", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster", "Top 500"]
            case .apex:         return ["Unranked", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Apex Predator"]
            case .valorant:     return ["Unranked", "Iron", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Immortal", "Radiant"]
            case .none:         return []
        }
    }

    func getMyPublishedEvents(){
        Task {
            do{
                myPublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: true, withSpecificOwner: true)
            } catch {
                //alertItem = AlertContext.unableToRetrieveEvents
                //isShowingAlert = true
            }
        }
    }

    func getMyUnpublishedEvents(){
        Task {
            do{
               myUnpublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: false, withSpecificOwner: true)
            } catch {
                //alertItem = AlertContext.unableToRetrieveEvents
                //isShowingAlert = true
            }
        }
    }
}
