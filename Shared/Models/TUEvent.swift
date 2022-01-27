//
//  TUEvent.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI
import CloudKit

struct TUEvent: Identifiable {

    static let kEventName         = "eventName"
    static let kEventDate         = "eventDate"
    static let kEventGame         = "eventGame"
    static let kEventDescription  = "eventDescription"
    static let kEventLocation     = "eventLocation"

    let id: CKRecord.ID

    let eventName: String
    let eventDate: Date
    let eventGame: String
    let eventDescription: String
    let eventLocation: String

    init(record: CKRecord){
        id = record.recordID

        eventName        = record[TUEvent.kEventName] as? String ?? "N/A"
        eventDate        = record[TUEvent.kEventDate] as? Date ?? Date()
        eventGame        = record[TUEvent.kEventGame] as? String ?? "N/A"
        eventDescription = record[TUEvent.kEventDescription] as? String ?? "N/A"
        eventLocation    = record[TUEvent.kEventLocation] as? String ?? "N/A"
    }

    var getDateDetails: DateComponents {
        let calendar = Calendar.current
        let dateDetails = DateComponents(
        year: calendar.component(.year, from: eventDate),
        month: calendar.component(.month, from: eventDate),
        day: calendar.component(.day, from: eventDate)
        )
    
        return dateDetails
    }

    var getMonth: String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "LLL"
         return dateFormatter.string(from: eventDate)
    }

    var getTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: eventDate)
    }
}
