//
//  EventsManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI

//MARK: EventsManager
@MainActor final class EventsManager: ObservableObject {

    @Published var events: [TUEvent]        = []
    @Published var players: [TUPlayer]      = []

    @Published var myPublishedEvents: [TUEvent]             = []
    @Published var myUnpublishedEvents: [TUEvent]           = []

    @Published var playerCountPerEvent: [CKRecord.ID:Int]   = [:]

    @Published var isShowingAlert            = false
    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    nonisolated func archiveEvents() async {
            do{
                for event in await events {
                    if Date() > event.eventEndDate {
                        let eventRecord = try await CloudKitManager.shared.fetchRecord(with: event.id)
                        eventRecord[TUEvent.kIsArchived] = 1
                        eventRecord[TUEvent.kIsPublished] = 0
                        let _ = try await CloudKitManager.shared.save(record: eventRecord)
                    }
                }
            } catch {
                print(error)
            }
    }

    func getPublicEvents(forGame: Game){
        Task {
            do{
                events  = try await CloudKitManager.shared.getEvents(thatArePublished: true, forGame: forGame, isArchived: false)
                //TIP: More efficient way of doing this?
                for event in events {
                    playerCountPerEvent[event.id] = try await CloudKitManager.shared.getPlayersForEvent(for: event.id).count
                }
            } catch {
                alertItem = AlertContext.unableToRetrieveEvents
                isShowingAlert = true
            }
        }
    }

    func getMyPublishedEvents(for owner: TUPlayer?){
        Task {
            do{
                if let owner = owner {
                    myPublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: true, withSpecificOwner: owner)
                }
            } catch {
                alertItem = AlertContext.unableToRetrieveEvents
                isShowingAlert = true
            }
        }
    }

    func getMyUnpublishedEvents(for owner: TUPlayer?){
        Task {
            do{
                if let owner = owner {
                    myUnpublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: false, withSpecificOwner: owner)
                }
            } catch {
                alertItem = AlertContext.unableToRetrieveEvents
                isShowingAlert = true
            }
        }
    }

    func deleteEvent(for event: TUEvent){
        Task{
            do {
                removePlayersFromEvent(eventID: event.id)
                let _ = try await CloudKitManager.shared.remove(recordID: event.id)
                
                if event.isPublished == 1 {
                    myPublishedEvents.removeAll(where: {$0.id == event.id})
                } else {
                    myUnpublishedEvents.removeAll(where: {$0.id == event.id})
                }
                events.removeAll(where: {$0.id == event.id})
            } catch{
                alertItem = AlertContext.unableToDeleteEvent
                isShowingAlert = true
            }
        }
    }

    private func removePlayersFromEvent(eventID: CKRecord.ID){
        Task{
            do {
                let playerRecordsInEvent = try await CloudKitManager.shared.getPlayerRecordsForEvent(for: eventID)
                let teamsFromDeletedEvent = try await CloudKitManager.shared.getTeamsFromEvent(for: eventID)

                for playerRecord in playerRecordsInEvent {
                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []
                    if !teamsFromDeletedEvent.isEmpty {
                        for teamReference in teamReferences {
                            //If team doesnt exist then remove from player's onTeams
                            if teamsFromDeletedEvent.contains(where: {$0.recordID == teamReference.recordID}){
                                teamReferences.removeAll(where: {$0 == teamReference})
                            }
                        }
                        playerRecord[TUPlayer.kOnTeams] = teamReferences
                    }

                    var eventReference = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []
                    eventReference.removeAll(where: {$0.recordID == eventID})
                    playerRecord[TUPlayer.kInEvents] = eventReference
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)
                }
            } catch {
                alertItem = AlertContext.unableToRemovePlayersFromEvent
                isShowingAlert = true
            }
        }
    }
}
