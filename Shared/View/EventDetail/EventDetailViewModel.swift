//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI
import EventKit

enum PresentingSheet {
    case addMatch, addPlayer, eventMoreDetail
}

enum DetailItem {
    case date,time,endTime,location,owner,game,school

    func getSystemImage() -> String {
        switch self {
        case .date:     return "calendar"
        case .time:     return "clock"
        case .location: return "map"
        case .endTime:  return "clock.badge.exclamationmark"
        case .owner:    return "person.text.rectangle"
        case .game:     return "gamecontroller.fill"
        case .school:   return "graduationcap.fill"
        }
    }

    func getTextHeading() -> String {
        switch self {
        case .date:     return "Date"
        case .time:     return "Start Time"
        case .location: return "Location"
        case .endTime:  return "End Time"
        case .owner:    return "Event Owner"
        case .game:     return "Event Game"
        case .school:   return "School"
        }
    }
}

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent

    init(event: TUEvent){
        self.event = event
        matchDate = event.eventStartDate
    }

    var store = EKEventStore()
    @Published var checkedOffPlayers: [TUPlayer]    = []
    @Published var availablePlayers: [TUPlayer]     = []
    @Published var searchedPlayers: [TUPlayer]      = []

    @Published var playersInEvent: [TUPlayer]       = []
    @Published var matches: [TUMatch]               = []

    @Published var matchName: String                = ""
    @Published var matchDate: Date                  = Date()

    @Published var searchString: String              = ""

    @Published var onAppearHasFired                 = false
    @Published var isShowingConfirmationDialogue    = false
    @Published var isLoading                        = false
    @Published var isShowingSheet                   = false
    @Published var isShowingCalendarView            = false
    @Published var isShowingPublishedButton         = true

    @Published var isShowingCreateMatchesView       = false
    @Published var sheetToPresent: PresentingSheet? {
        didSet{
            isShowingSheet = true
        }
    }

    @Published var isShowingAlert: Bool             = false
    @Published var alertItem: AlertItem             = AlertItem(alertTitle: Text("Unable To Show Alert"),
                                                                alertMessage: Text("There was a problem showing the alert."))

    func isEventOwner(for playerRecord: CKRecord?) -> Bool {
        if let playerRecord = playerRecord {
            return event.eventOwner.recordID == playerRecord.recordID
        }
        return false
    }

    //INFO: Returns range of dates from the event date onwards
    func dateRange() -> PartialRangeFrom<Date> {
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: event.eventStartDate),
            month: calendar.component(.month, from: event.eventStartDate),
            day: calendar.component(.day, from: event.eventStartDate)
        )
        return calendar.date(from:startDate)!...
    }

    //INFO: Checks whether user has calendar access, alerts if doesn't
    nonisolated func checkCalendarAcces() async {
        do {
            let hasGivenAccess = try await store.requestAccess(to: .event)
            if hasGivenAccess {
                await MainActor.run{
                    isShowingCalendarView = true
                }
            } else {
               
                await MainActor.run{
                    alertItem = AlertContext.unableToAccessCalendar
                    isShowingAlert = true
                }
            }
        } catch {}
    }

    func refreshEventDetails(){
        getMatchesForEvent()
        getPlayersInEvents()
    }

    func setUpEventDetails(){
        //MARK: Prevents from being called twice. Bug in SwiftUI
        if !onAppearHasFired {
            getMatchesForEvent()
            getPlayersInEvents()
            onAppearHasFired = true
        }
    }

    //INFO: Presents a sheet based on PresentingSheet enumerator
    @ViewBuilder func presentSheet() -> some View {
        switch sheetToPresent {
            case .eventMoreDetail:
                EventMoreDetailSheet(viewModel: self)
            case .addMatch:
                AddMatchSheet(viewModel: self)
            case .addPlayer:
                AddPlayerToEventSheet(viewModel: self)
            case .none:
                EmptyView()
        }
    }

    func resetMatchInput(){
        matchName = ""
        matchDate = event.eventStartDate
    }

    //INFO: Creates Match CKRecord with match: Name, Date, & Reference to event
    private func createMatchRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.match)

        record[TUMatch.kMatchName]     = matchName
        record[TUMatch.kStartTime]     = matchDate
        record[TUMatch.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)

        return record
    }

    //INFO: Returns T/F if creating match is valid based on if name is empty and match date is ahead of event date
    private func isValidMatch() -> Bool{
        guard !matchName.isEmpty, matchDate >= event.eventStartDate, matchDate <= event.eventEndDate else {
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

                //TIP: Reloads view, locally adds player until another network call is made
                matches.append(TUMatch(record: matchRecord))
                matches.sort(by: {$0.matchStartTime < $1.matchStartTime})
                isShowingSheet = false
            } catch {
                alertItem = AlertContext.unableToCreateMatch
                isShowingAlert = true
            }
        }
    }

    func addPlayerToEvent(with playerManager: PlayerManager){
        Task {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerManager.playerProfile!.id)

                var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                if references.isEmpty{
                    playerRecord[TUPlayer.kInEvents] = [CKRecord.Reference(recordID: event.id, action: .none)]
                } else {
                    references.append(CKRecord.Reference(recordID: event.id, action: .none))
                    playerRecord[TUPlayer.kInEvents] = references
                }

                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                playersInEvent.append(playerManager.playerProfile!)
                playersInEvent = playersInEvent.sorted(by: {$0.firstName < $1.firstName})
                await playerManager.getRecordAndPlayerProfile()
            } catch {
                //MARK: Unable to add you to event
                alertItem = AlertContext.unableToAddSelectedPlayersToEvent
                isShowingAlert = true
            }
        }
    }

    func leaveEvent(with playerManager: PlayerManager){
        Task {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerManager.playerProfile!.id)

                var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                if !references.isEmpty{
                    references.removeAll(where: {$0.recordID == event.id})
                    playerRecord[TUPlayer.kInEvents] = references
                }

                let _ = try await CloudKitManager.shared.save(record: playerRecord)

                playersInEvent.removeAll(where: {$0.id == playerManager.playerProfile!.id})
                await playerManager.getRecordAndPlayerProfile()
            } catch {
                //MARK: Unable to add leave event
                alertItem = AlertContext.unableToAddSelectedPlayersToEvent
                isShowingAlert = true
            }
        }
    }

    //INFO: For Event owners to search players and manually add them to their event
    func addCheckedPlayersToEvent(){
        Task {
            do {
                for player in checkedOffPlayers {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                    if references.isEmpty{
                        playerRecord[TUPlayer.kInEvents] = [CKRecord.Reference(recordID: event.id, action: .none)]
                    } else {
                        references.append(CKRecord.Reference(recordID: event.id, action: .none))
                        playerRecord[TUPlayer.kInEvents] = references
                    }
                    
                    let _ = try await CloudKitManager.shared.save(record: playerRecord)

                    playersInEvent.append(player)
                    playersInEvent = playersInEvent.sorted(by: {$0.firstName < $1.firstName})
                }
            } catch {
                alertItem = AlertContext.unableToAddSelectedPlayersToEvent
                isShowingAlert = true
            }
        }
    }

    func publishEvent(eventsManager: EventsManager){
        if event.eventStartDate < Date() {
            alertItem = AlertContext.eventPastStartTime
            isShowingAlert = true
        } else {
            Task {
                do {
                    let eventRecord = try await CloudKitManager.shared.fetchRecord(with: event.id)
                    eventRecord[TUEvent.kIsPublished] = 1
                    let _ = try await CloudKitManager.shared.save(record: eventRecord)
                    isShowingPublishedButton = false
                } catch {
                    alertItem = AlertContext.unableToPublishEvent
                    isShowingAlert = true
                }
            }
        }
    }

    //INFO: Gets called on appearance of event detail view
    private func getMatchesForEvent(){
        showLoadingView()
        Task {
            do {
                let loadingMatches =  try await CloudKitManager.shared.getMatches(for: event.id)
                matches = loadingMatches
                hideLoadingView()
            } catch{
                hideLoadingView()
                alertItem = AlertContext.unableToGetMatchesForEvent
                isShowingAlert = true
            }
        }
    }

    //INFO: Gets called on appearance of event detail view
    private func getPlayersInEvents(){
        showLoadingView()
        Task {
            do {
                let loadingPlayers = try await CloudKitManager.shared.getPlayersForEvent(for: event.id)
                playersInEvent = loadingPlayers
                hideLoadingView()
            } catch{
                hideLoadingView()
                alertItem = AlertContext.unableToGetPlayersForEvent
                isShowingAlert = true
            }
        }
    }

    //INFO: Fetches list of players based of search
    func getSearchedPlayers(with searchString: String) {
        Task {
            do {
                availablePlayers =  try await CloudKitManager.shared.getPlayers(with: searchString)
            } catch {
                alertItem = AlertContext.unableToSearchForPlayers
                isShowingAlert = true
            }
        }
    }

    //INFO: Removes player's reference to event and any references of a team within event
    func removePlayerFromEventWith(for player: TUPlayer){
            Task {
                do {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)

                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == event.id})

                    playerRecord[TUPlayer.kInEvents] = references

                    let teamsInEvents = try await CloudKitManager.shared.getTeamsFromEvent(for: event.id)

                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []

                    //TIP: Make into dictionary?
                    if !teamsInEvents.isEmpty {
                        for teamReference in teamReferences {
                            //INFO: If team doesnt exist then remove from player's onTeams
                            if teamsInEvents.contains(where: {$0.recordID == teamReference.recordID}){
                                teamReferences.removeAll(where: {$0 == teamReference})
                            }
                        }
                        playerRecord[TUPlayer.kOnTeams] = teamReferences
                    }

                    let _ = try await CloudKitManager.shared.save(record: playerRecord)

                    playersInEvent.removeAll(where: {$0.id == player.id})
                } catch{
                    alertItem = AlertContext.unableToRemovePlayerFromTeam
                    isShowingAlert = true
                }
            }
    }

    private func showLoadingView(){isLoading = true}
    private func hideLoadingView(){isLoading = false}
}
