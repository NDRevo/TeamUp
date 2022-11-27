//
//  MyEventsViewModel.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import CloudKit
import SwiftUI

enum EventError: Error {
    case InvalidEvent
    case unableToCreateEvent
}

@MainActor final class MyEventsViewModel: ObservableObject {

    let locations: [locations] = [.irl, .discord]

    @Published var eventName: String         = ""
    @Published var eventSchool: String       = ""
    @Published var eventDescription: String  = ""
    @Published var eventLocationTitle: String?
    @Published var eventLocation: String     = ""
    @Published var eventDate: Date           = Date()
    @Published var eventEndDate: Date        = Date()
    @Published var eventGame: Game           = Game(name: GameNames.other, ranks: [])
    @Published var eventGameVariant: Game    = Game(name: GameNames.empty, ranks: [])

    @Published var isPresentingAddEvent      = false
    @Published var isPresentingMap           = false
    @Published var isShowingAlert            = false

    @Published var locationPicked: locations = .irl

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
        eventName        = ""
        eventDate        = currentDateAndHour
        eventEndDate     = Calendar.current.date(byAdding: .hour, value: 1, to: currentDateAndHour)!
        eventGame        = Game(name: GameNames.other, ranks: [])
        eventGameVariant = Game(name: GameNames.empty, ranks: [])
        eventDescription = ""
        eventLocationTitle = nil
        eventLocation    = ""
        locationPicked   = .irl
    }

    //INFO: Used to set default date and hour for creating an event
    private var currentDateAndHour: Date = {
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

    private func createEventRecord(with profile: TUPlayer?, profileRecord: CKRecord?) -> CKRecord{
        let record = CKRecord(recordType: RecordType.event)
        record[TUEvent.kEventName]              = eventName
        record[TUEvent.kEventStartDate]         = eventDate
        record[TUEvent.kEventEndDate]           = eventEndDate
        record[TUEvent.kEventGameName]          = eventGame.name
        record[TUEvent.kEventGameVariantName]   = eventGameVariant.name
        record[TUEvent.kEventDescription]       = eventDescription

        if locationPicked == .discord {
            record[TUEvent.kEventLocation] = "discord.gg/\(eventLocation)"
        } else {
            record[TUEvent.kEventLocationTitle] = eventLocationTitle
            record[TUEvent.kEventLocation] = eventLocation
        }

        record[TUEvent.kIsPublished]            = 0
        record[TUEvent.kIsArchived]             = 0
        
        if let profile = profile {
            record[TUEvent.kEventOwner]         = CKRecord.Reference(record: profileRecord!, action: .none)
            record[TUEvent.kEventOwnerName]     = profile.username
            record[TUEvent.kEventSchool]        = profile.inSchool
            record[TUEvent.kEventSchoolClub]    = profile.clubLeaderClubName
        }
        return record
    }

    func createEvent(for eventsManager: EventsManager, from profileRecord: CKRecord?, with profile: TUPlayer?) throws {
        guard isValidEvent() else {
            alertItem = AlertContext.invalidEvent
            isShowingAlert = true
            return
        }

        Task {
            do {
                let event = createEventRecord(with: profile, profileRecord: profileRecord)
                let _ = try await CloudKitManager.shared.save(record: event)

                //TIP: Reloads view, locally adds player until another network call is made
                eventsManager.myUnpublishedEvents.append(TUEvent(record: event))
                eventsManager.myUnpublishedEvents.sort(by: {$0.eventStartDate < $1.eventStartDate})
                isPresentingAddEvent = false
            } catch {
                alertItem = AlertContext.unableToCreateEvent
                isShowingAlert = true
            }
        }
    }
}
