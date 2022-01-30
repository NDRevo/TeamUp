//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventsListViewModel: ObservableObject {

    @Published var eventName: String         = ""
    @Published var eventDate: Date           = Date()
    @Published var eventGame: Games          = .valorant
    @Published var eventDescription: String  = ""
    @Published var eventLocation: String     = ""

    @Published var onAppearHasFired          = false
    @Published var isPresentingAddEvent      = false
    @Published var isShowingAlert            = false

    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    let dateRange: PartialRangeFrom<Date> = {
        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: date) + 1
        )
        return calendar.date(from:startDate)!...
    }()

    var currentDateAndHour: Date = {
        let date = Date()
        let calendar = Calendar.current
        let mock = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: date) + 1,
            minute: 00
        )
        
        return calendar.date(from: mock)!
    }()

    func resetInput(){
        eventName = ""
        eventDate = currentDateAndHour
        eventGame = .valorant
        eventDescription = ""
        eventLocation = ""
    }

    private func isValidEvent() -> Bool{
        guard !eventName.isEmpty,
              eventDate >= Date(),
              !eventDescription.isEmpty,
              !eventLocation.isEmpty else{
            return false
        }
        return true
    }

    func refresh(for eventsManager: EventsManager){
        getEvents(for: eventsManager)
        getPlayers(for: eventsManager)
        getPlayersAndDetails(for: eventsManager)
    }

    func startUp(for eventsManager: EventsManager){
        //Forces app to call this once, but would force user to pull to refresh to get new events
        //Fixed flashing list cell
        if !onAppearHasFired {
            getEvents(for: eventsManager)
            getPlayers(for: eventsManager)
            getPlayersAndDetails(for: eventsManager)
        }
        onAppearHasFired = true
    }

    private func createEventRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.event)
        record[TUEvent.kEventName]          = eventName
        record[TUEvent.kEventDate]          = eventDate
        record[TUEvent.kEventGame]          = eventGame.rawValue
        record[TUEvent.kEventDescription]   = eventDescription
        record[TUEvent.kEventLocation]      = eventLocation
        
        if let userRecord = CloudKitManager.shared.userRecord {
            record[TUEvent.kEventOwner] = CKRecord.Reference(record: userRecord, action: .none)
        }

        return record
    }

    func createEvent(for eventsManager: EventsManager) {
        guard isValidEvent() else {
            alertItem = AlertContext.invalidEvent
            isShowingAlert = true
            return
        }

        Task {
            do {
                let event = createEventRecord()
                let _ = try await CloudKitManager.shared.save(record: event)

                //Reloads view, locally adds player until another network call is made
                eventsManager.events.append(TUEvent(record: event))
                eventsManager.events.sort(by: {$0.eventDate < $1.eventDate})
            } catch {
                alertItem = AlertContext.unableToCreateEvent
                isShowingAlert = true
            }
        }
    }

    private func getEvents(for eventsManager: EventsManager){
        Task {
            do{
                eventsManager.events  = try await CloudKitManager.shared.getEvents()
                
                //More efficient way of doing this?
                for event in eventsManager.events {
                    eventsManager.playerCountPerEvent[event.id] = try await CloudKitManager.shared.getPlayersForEvent(for: event.id).count
                }
            } catch {
                alertItem = AlertContext.unableToRetrieveEvents
                isShowingAlert = true
            }
        }
    }

    private func getPlayers(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.players = try await CloudKitManager.shared.getPlayers()
            } catch {
                alertItem = AlertContext.unableToGetPlayerList
                isShowingAlert = true
            }
        }
    }

    private func getPlayersAndDetails(for eventsManager: EventsManager){
        Task {
            do {
                eventsManager.playerDetails = try await CloudKitManager.shared.getPlayersAndDetails()
            } catch {
                alertItem = AlertContext.unableToGetPlayerDetails
                isShowingAlert = true
            }
        }
    }

    private func removePlayersFromEvent(eventID: CKRecord.ID){
        Task{
            do {
                let playerRecordsInEvent = try await CloudKitManager.shared.getPlayerRecordsForEvent(for: eventID)
                let teamsFromDeleteEvent = try await CloudKitManager.shared.getTeamsFromEvent(for: eventID)

                for playerRecord in playerRecordsInEvent {
                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []
                    if teamsFromDeleteEvent.isEmpty {
                        teamReferences.removeAll()
                        playerRecord[TUPlayer.kOnTeams] = teamReferences
                    } else {
                        for teamReference in teamReferences {
                            //If team doesnt exist then remove from player's onTeams
                            if teamsFromDeleteEvent.contains(where: {$0.recordID == teamReference.recordID}){
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

    func deleteEvent(eventID: CKRecord.ID){
        Task{
            do {
                removePlayersFromEvent(eventID: eventID)
                let _ = try await CloudKitManager.shared.remove(recordID: eventID)
            } catch{
                alertItem = AlertContext.unableToDeleteEvent
                isShowingAlert = true
            }
        }
    }
}
