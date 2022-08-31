//
//  TUEvent.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI
import CloudKit

struct TUEvent: Identifiable, Hashable {

    static let kEventName               = "eventName"
    static let kEventStartDate          = "eventDate"
    static let kEventEndDate            = "eventEndDate"
    static let kEventGameName           = "eventGameName"
    static let kEventGameVariantName    = "eventGameVariantName"
    static let kEventDescription        = "eventDescription"
    static let kEventLocation           = "eventLocation"
    static let kEventSchool             = "eventSchool"
    static let kEventOwner              = "eventOwner"
    static let kEventOwnerName          = "eventOwnerName"
    static let kIsPublished             = "isPublished"

    let id: CKRecord.ID

    let eventName: String
    let eventStartDate: Date
    let eventEndDate: Date
    let eventGameName: String
    let eventGameVariantName: String
    let eventDescription: String
    let eventLocation: String
    let eventOwner: CKRecord.Reference
    let eventOwnerName: String
    let eventSchool: String
    let isPublished: Int

    init(record: CKRecord){
        id = record.recordID

        eventName               = record[TUEvent.kEventName] as? String ?? "N/A"
        eventStartDate          = record[TUEvent.kEventStartDate] as? Date ?? Date()
        eventEndDate            = record[TUEvent.kEventEndDate] as? Date ?? Date()
        eventGameName           = record[TUEvent.kEventGameName] as? String ?? "N/A"
        eventGameVariantName    = record[TUEvent.kEventGameVariantName] as? String ?? ""
        eventDescription        = record[TUEvent.kEventDescription] as? String ?? "N/A"
        eventLocation           = record[TUEvent.kEventLocation] as? String ?? "N/A"
        //MARK: Forced Unwrapped since this will never be nil
        //MARK: Optional value to resolve canvas previews
        eventOwner              = record[TUEvent.kEventOwner] as? CKRecord.Reference ?? CKRecord.Reference(recordID: CKRecord.ID(recordName: "31394CE3-68AD-4AC2-A125-59E665637500"), action: .deleteSelf)
        eventOwnerName          = record[TUEvent.kEventOwnerName] as? String ?? "N/A"
        eventSchool             = record[TUEvent.kEventSchool] as? String ?? "N/A"
        isPublished             = record[TUEvent.kIsPublished] as? Int ?? 0
    }

    var getDateDetails: DateComponents {
        let calendar = Calendar.current
        let dateDetails = DateComponents(
        year: calendar.component(.year, from: eventStartDate),
        month: calendar.component(.month, from: eventStartDate),
        day: calendar.component(.day, from: eventStartDate)
        )
    
        return dateDetails
    }

    var getMonth: String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "LLL"
         return dateFormatter.string(from: eventStartDate)
    }

    var getTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: eventStartDate)
    }

    var getEndTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: eventEndDate)
    }

    var getEventDetailDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: eventStartDate)
    }
}
