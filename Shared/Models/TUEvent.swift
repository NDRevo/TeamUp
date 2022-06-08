//
//  TUEvent.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI
import CloudKit

struct TUEvent: Identifiable, Hashable {

    static let kEventName         = "eventName"
    static let kEventDate         = "eventDate"
    static let kEventGame         = "eventGame"
    static let kEventDescription  = "eventDescription"
    static let kEventLocation     = "eventLocation"
    static let kEventOwner        = "eventOwner"

    let id: CKRecord.ID

    let eventName: String
    let eventDate: Date
    let eventGame: String
    let eventDescription: String
    let eventLocation: String
    let eventOwner: CKRecord.Reference

    init(record: CKRecord){
        id = record.recordID

        eventName        = record[TUEvent.kEventName] as? String ?? "N/A"
        eventDate        = record[TUEvent.kEventDate] as? Date ?? Date()
        eventGame        = record[TUEvent.kEventGame] as? String ?? "N/A"
        eventDescription = record[TUEvent.kEventDescription] as? String ?? "N/A"
        eventLocation    = record[TUEvent.kEventLocation] as? String ?? "N/A"
        //Forced Unwrapped since this will never be nil
        eventOwner       = record[TUEvent.kEventOwner] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "31394CE3-68AD-4AC2-A125-59E665637500"), action: .deleteSelf)
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
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: eventDate)
    }

    var getEventDetailDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: eventDate)
    }
}
