//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent

    init(event: TUEvent){
        self.event = event
    }

    @Published var isShowingAddMatch            = false
    @Published var isShowingAddPlayerToEvent    = false
    @Published var isShowingAddAdmin            = false

    @Published var matchName: String = ""
    @Published var matchDate: Date = Date()

    //Players that join/added to the event from the players list
    @Published var players: [TUPlayer] = []
    @Published var matches: [TUMatch] = []

    func createMatchRecord() -> CKRecord {
        let record = CKRecord(recordType: RecordType.match)

        record[TUMatch.kMatchName]     = matchName
        record[TUMatch.kStartTime]     = matchDate
        record[TUMatch.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)

        return record
    }
    
    func createMatchForEvent(){
        Task{
            do{
                let matchRecord = createMatchRecord()
                let _ = try await CloudKitManager.shared.save(record: matchRecord)

                //Reloads view, locally adds player until another network call is made
                matches.append(TUMatch(record: matchRecord))
            }catch{
                //Alert could not save match
            }
        }
    }
    
    func getMatchesForEvent(){
        Task {
            do {
                matches = try await CloudKitManager.shared.getMatches(for: event.id)
            } catch{
                //Alert could not get matches
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
                //Alert couldnt remove player
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
