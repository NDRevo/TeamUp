//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent

    init(event: TUEvent){
        self.event = event
        matchDate = event.eventDate
    }

    //Players that join/added to the event from the players list
    @Published var players: [TUPlayer] = []
    @Published var matches: [TUMatch] = []

    @Published var matchName: String = ""
    @Published var matchDate: Date = Date()

    @Published var isShowingAddMatch            = false
    @Published var isShowingAddPlayerToEvent    = false
    @Published var isShowingAddAdmin            = false
    
    @Published var isShowingAlert: Bool         = false
    @Published var alertItem: AlertItem         = AlertItem(alertTitle: Text("Unable To Show Alert"),
                                                            alertMessage: Text("There was a problem showing the alert."))
    
    @Environment(\.dismiss) var dismiss

    func resetMatchInput(){
        matchName = ""
        matchDate = event.eventDate
    }

    private func createMatchRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.match)

        record[TUMatch.kMatchName]     = matchName
        record[TUMatch.kStartTime]     = matchDate
        record[TUMatch.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)

        return record
    }

    private func isValidMatch() -> Bool{
        guard !matchName.isEmpty, matchDate >= event.eventDate else {
            return false
        }
        return true
    }

    func createMatchForEvent(){
        guard isValidMatch() else {
            alertItem = AlertContext.invalidMatch
            isShowingAlert = true
            return
        }

        Task{
            do{
                let matchRecord = createMatchRecord()
                let _ = try await CloudKitManager.shared.save(record: matchRecord)

                //Reloads view, locally adds player until another network call is made
                matches.append(TUMatch(record: matchRecord))
            } catch {
                alertItem = AlertContext.unableToCreateMatch
                isShowingAlert = true
            }
        }
    }
    
    func getMatchesForEvent(){
        Task {
            do {
                matches = try await CloudKitManager.shared.getMatches(for: event.id)
            } catch{
                alertItem = AlertContext.unableToGetMatchesForEvent
                isShowingAlert = true
            }
        }
    }
    
    func deleteMatch(recordID: CKRecord.ID){
        Task {
            do {
                let _ = try await CloudKitManager.shared.remove(recordID: recordID)

                //Reloads view, locally adds player until another network call is made
                matches.removeAll(where: {$0.id == recordID})
            } catch {
                alertItem = AlertContext.unableToDeleteMatch
                isShowingAlert = true
            }
        }
    }
    
    func dateRange() -> PartialRangeFrom<Date> {
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: event.eventDate),
            month: calendar.component(.month, from: event.eventDate),
            day: calendar.component(.day, from: event.eventDate)
        )
        return calendar.date(from:startDate)!...
    }
}
