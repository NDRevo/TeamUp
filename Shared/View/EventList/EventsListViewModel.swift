//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import Foundation
import CloudKit

@MainActor final class EventsListViewModel: ObservableObject {

    @Published var isPresentingAddEvent: Bool = false

    @Published var eventName: String          = ""
    @Published var eventDate: Date            = Date()
    @Published var eventGame: Games           = .valorant
    @Published var eventLocation: String      = ""
    
    //HANDLE LATER: Stops app from calling getEvents() twice in .task modifier: Swift Bug
    @Published var onAppearHasFired = false
    
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
    
    func createEvent(for eventsManager: EventsManager) {
        let event = createEventRecord()
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: event)

                //Reloads view, locally adds player until another network call is made
                eventsManager.events.append(TUEvent(record: event))
            } catch {
                //Error: Could not create event, try again later
            }
        }
    }
    
    func getEvents(for eventsManager: EventsManager){
        Task {
            do{
                eventsManager.events  = try await CloudKitManager.shared.getEvents()
            } catch {
                //Alert could not get events
            }
        }
    }
    
    func deleteEvent(recordID: CKRecord.ID){
        Task{
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)
            } catch{
                //Alert: could not delete event
            }
        }
    }
    
    
}
