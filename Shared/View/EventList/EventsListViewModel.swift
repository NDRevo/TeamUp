//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventsListViewModel: ObservableObject {

    @Published var eventName: String          = ""
    @Published var eventDate: Date            = Date()
    @Published var eventGame: Games           = .valorant
    @Published var eventLocation: String      = ""
    
    //HANDLE LATER: Stops app from calling getEvents() twice in .task modifier: Swift Bug
    @Published var onAppearHasFired          = false
    @Published var isPresentingAddEvent      = false
    @Published var isShowingAlert            = false
    @Published var createEventButtonPressed  = false
    
    @Published var alertItem: AlertItem     = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

    let dateRange: PartialRangeFrom<Date> = {
        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
        return calendar.date(from:startDate)!...
    }()
    
    var mockDate: Date = {
        let date = Date()
        let calendar = Calendar.current
        let mock = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: 7,
            minute: 00
        )
        
        return calendar.date(from: mock)!
    }()
    
    private func createEventRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.event)
        record[TUEvent.kEventName]     = eventName
        record[TUEvent.kEventDate]     = eventDate
        record[TUEvent.kEventGame]     = eventGame.rawValue
        record[TUEvent.kEventLocation] = eventLocation
        
        return record
    }
    
    func resetInput(){
        eventName = ""
        eventDate = mockDate
        eventGame = .valorant
        eventLocation = ""
    }
    
    private func isValidEvent() -> Bool{
        guard !eventName.isEmpty,
              eventDate > Date(),
              !eventLocation.isEmpty else {
            return false
        }
        return true
    }
    
    func startUp(for eventsManager: EventsManager){
        getEvents(for: eventsManager)
        getPlayers(for: eventsManager)
        getPlayersAndDetails(for: eventsManager)
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
            } catch {
                alertItem = AlertContext.unableToCreateEvent
                isShowingAlert = true
            }
        }
    }
    
    func getEvents(for eventsManager: EventsManager){
        Task {
            do{
                eventsManager.events  = try await CloudKitManager.shared.getEvents()
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
                let playersInEvent = try await CloudKitManager.shared.getPlayersForEvent(for: eventID)

                for player in playersInEvent {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)

                    let allTeams = try await CloudKitManager.shared.getTeamsRecordID()

                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []
                    if allTeams.isEmpty {
                        teamReferences.removeAll()
                        playerRecord[TUPlayer.kOnTeams] = teamReferences
                    } else {
                        for teamReference in teamReferences {
                            if !allTeams.contains(where: {$0 == teamReference.recordID}){
                                teamReferences.removeAll(where: {$0 == teamReference})
                                playerRecord[TUPlayer.kOnTeams] = teamReferences
                            }
                        }
                    }
                    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []
                    references.removeAll(where: {$0.recordID == eventID})
                    playerRecord[TUPlayer.kInEvents] = references
                    
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
