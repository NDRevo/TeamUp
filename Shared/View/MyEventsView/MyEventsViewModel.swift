//
//  MyEventsViewModel.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import CloudKit
import SwiftUI

@MainActor final class MyEventsViewModel: ObservableObject {

    @Published var eventName: String         = ""
    @Published var eventDate: Date           = Date()
    @Published var eventEndDate: Date        = Date()
    @Published var eventGame: Games          = .apexlegends
    @Published var eventDescription: String  = ""
    @Published var eventLocation: String     = ""
    
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

    func resetInput(){
        eventName = ""
        eventDate = currentDateAndHour
        eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDateAndHour)!
        eventGame = .none
        eventDescription = ""
        eventLocation = ""
    }

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

    private func isValidEvent() -> Bool {
        guard !eventName.isEmpty,
              eventDate >= Date(),
              !eventDescription.isEmpty,
              !eventLocation.isEmpty,
              eventEndDate >= eventDate
        else {
            return false
        }
        return true
    }

    private func createEventRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.event)
        record[TUEvent.kEventName]          = eventName
        record[TUEvent.kEventDate]          = eventDate
        record[TUEvent.kEventEndDate]       = eventEndDate
        record[TUEvent.kEventGame]          = eventGame.rawValue
        record[TUEvent.kEventDescription]   = eventDescription
        record[TUEvent.kEventLocation]      = eventLocation
        record[TUEvent.kIsPublished]        = 0
        
        if let userRecord = CloudKitManager.shared.userRecord {
            record[TUEvent.kEventOwner] = CKRecord.Reference(record: userRecord, action: .none)
        }

        return record
    }

    func createEvent(for eventsManager: EventsManager) throws {
        guard isValidEvent() else {
            alertItem = AlertContext.invalidEvent
            throw EventError.InvalidEvent
        }

        Task {
            do {
                let event = createEventRecord()
                let _ = try await CloudKitManager.shared.save(record: event)

                //TIP: Reloads view, locally adds player until another network call is made
                eventsManager.myUnpublishedEvents.append(TUEvent(record: event))
                eventsManager.myUnpublishedEvents.sort(by: {$0.eventDate < $1.eventDate})
            } catch {
                alertItem = AlertContext.unableToCreateEvent
                throw EventError.unableToCreateEvent
            }
        }
    }
    
    enum EventError: Error {
        case InvalidEvent
        case unableToCreateEvent
    }
}
