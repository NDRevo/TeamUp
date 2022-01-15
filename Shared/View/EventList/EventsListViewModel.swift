//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import Foundation
import CloudKit

final class EventsListViewModel: ObservableObject {

    @Published var isPresentingAddEvent: Bool = false

    @Published var eventName: String          = ""
    @Published var eventDate: Date            = Date()
    @Published var eventGame: Games           = .VALORANT
    @Published var eventLocation: String      = ""
    
    
    private func createEventRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.event)
        record[TUEvent.kEventName]     = eventName
        record[TUEvent.kEventDate]     = eventDate
        record[TUEvent.kEventGame]     = eventGame.rawValue
        record[TUEvent.kEventLocation] = eventLocation
        
        return record
    }
    
    func createEvent() {
        let event = createEventRecord()
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: event)
            } catch {
                //Error: Could not create event, try again later
            }
        }
    }
}
