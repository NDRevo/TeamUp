//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI
import EventKit


/// Determines what sheet to present
enum PresentingSheet {
    case addMatch, addPlayer, eventMoreDetails
}

enum DetailItem {
    case date,time,endTime,location,owner,game,school, clubHosting

    func getSystemImage() -> String {
        switch self {
        case .date:     return "calendar"
        case .time:     return "clock"
        case .location: return "map"
        case .endTime:  return "clock.badge.exclamationmark"
        case .owner:    return "person.text.rectangle"
        case .game:     return "gamecontroller.fill"
        case .school:   return "graduationcap.fill"
        case .clubHosting: return "suit.club.fill"
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
        case .clubHosting: return "Club Hosting"
        }
    }
}

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent
    var eventLocationType: Locations {  return event.eventLocation.starts(with: "discord.gg") ? .discord : .irl }
    var eventDateRange: PartialRangeFrom<Date>

    init(event: TUEvent){
        self.event = event
        matchDate = event.eventStartDate

        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: date)
        )
        eventDateRange = calendar.date(from:startDate)!...
    }

    var store = EKEventStore()
    @Published var checkedOffPlayers: [TUPlayer]    = []
    @Published var availablePlayers: [TUPlayer]     = []
    @Published var searchedPlayers: [TUPlayer]      = []

    @Published var playersInEvent: [TUPlayer]       = []
    @Published var matches: [TUMatch]               = []

    @Published var matchName: String                = ""
    @Published var matchDate: Date                  = Date()

    // Editing Event
    @Published var searchString: String             = ""
    @Published var editedEventName: String = ""
    @Published var editedDescription: String = ""
    @Published var editedLocationTypePicked: Locations = .irl
    @Published var editedLocationTitle: String?
    @Published var editedLocationName: String = ""
    @Published var editedEventStartDate: Date = Date()
    @Published var editedEventEndDate: Date = Date()
    @Published var userInputEditedEventGameName: String = ""
    @Published var editedEventGame: Game = Game(name: GameNames.amongus, ranks: [])
    @Published var editedEventGameVariant: Game = Game(name: GameNames.empty, ranks: [])

    @Published var onAppearHasFired                 = false
    @Published var isShowingConfirmationDialogue    = false
    @Published var isLoading                        = false
    @Published var isShowingSheet                   = false
    @Published var isShowingCalendarView            = false
    @Published var isShowingPublishedButton         = true

    @Published var isPresentingMap                  = false
    @Published var isEditingEventDetails            = false {
        didSet {
            switch self.isEditingEventDetails {
            case true:
                editedDescription = event.eventDescription
                editedLocationTypePicked = eventLocationType
                editedLocationTitle = eventLocationType == .discord ? "" : event.eventLocationTitle
                editedLocationName = eventLocationType == .discord ? String(event.eventLocation.split(separator: "/", omittingEmptySubsequences: true)[1]) : event.eventLocation
                editedEventStartDate = event.eventStartDate
                editedEventEndDate = event.eventEndDate
                editedEventGame = GameLibrary.data.getGameByName(gameName: event.eventGameName)
                editedEventGameVariant = GameLibrary.data.getGameVariantByGameName(gameName: event.eventGameName, gameVariantName: event.eventGameVariantName)
            case false:
                editedEventName = ""
                editedDescription = ""
                editedLocationName = ""
            }
        }
    }

    @Published var isShowingCreateMatchesView       = false
    @Published var sheetToPresent: PresentingSheet? {
        didSet{
            isShowingSheet = true
        }
    }
    //Publishing Changes Issue
    @Published var isShowingEventDetailViewAlert: Bool = false
    @Published var isShowingAddMatchSheetAlert: Bool = false
    var alertItem: AlertItem = AlertItem(alertTitle: Text("Unable To Show Alert"), alertMessage: Text("There was a problem showing the alert."))

    /// Check to see if user is owner of event
    /// - Parameter playerRecord: CKRecord of player being checked
    /// - Returns: Bool
    func isEventOwner(for playerRecord: CKRecord?) -> Bool {
        if let playerRecord = playerRecord {
            return event.eventOwner.recordID == playerRecord.recordID
        }
        return false
    }

    /// dateRange
    /// - Returns: Range from event start. Used to created match within date range of event inclusive
    func dateRange() -> PartialRangeFrom<Date> {
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: event.eventStartDate),
            month: calendar.component(.month, from: event.eventStartDate),
            day: calendar.component(.day, from: event.eventStartDate)
        )
        return calendar.date(from:startDate)!...
    }

    /// Used to determine if user has given app access to calendar
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
                    isShowingEventDetailViewAlert = true
                }
            }
        } catch {}
    }

    /// Fetches matches and players in event upon pull to refresh
    func refreshEventDetails(){
        getMatchesForEvent()
        getPlayersInEvents()
    }

    /// Fetches matches and players in events at first launch
    func setUpEventDetails(){
        //MARK: Prevents from being called twice. Bug in SwiftUI
        if !onAppearHasFired {
            getMatchesForEvent()
            getPlayersInEvents()
            onAppearHasFired = true
        }
    }

    /// Presents a sheet based on PresentingSheet enumerator
    /// - Returns: A sheet view
    @ViewBuilder
    func presentSheet() -> some View {
        switch sheetToPresent {
            case .eventMoreDetails:
                EventMoreDetailsSheet(viewModel: self)
            case .addMatch:
                AddMatchSheet(viewModel: self)
            case .addPlayer:
                AddPlayerToEventSheet(viewModel: self)
            case .none:
                EmptyView()
        }
    }

    /// Resets user input from add match sheet
    func resetMatchInput(){
        matchName = ""
        matchDate = event.eventStartDate
    }

    /// Creates Match CKRecord with match: Name, Date, & Reference to event
    /// - Returns: CKRecord used to save in CloudKit
    private func createMatchRecord() -> CKRecord{
        let record = CKRecord(recordType: RecordType.match)

        record[TUMatch.kMatchName]     = matchName
        record[TUMatch.kStartTime]     = matchDate
        record[TUMatch.kAssociatedToEvent] = CKRecord.Reference(recordID: event.id, action: .deleteSelf)

        return record
    }

    ///  Checks if valid based on if name is empty and match date is ahead of event date
    /// - Returns: Bool
    private func isValidMatch() -> Bool{
        guard !matchName.isEmpty, matchDate >= event.eventStartDate, matchDate <= event.eventEndDate else {
            return false
        }
        return true
    }

    /// Calls to create TUMatch record and saves to cloudkit
    func createMatchForEvent(){
        guard isValidMatch() else {
            alertItem = AlertContext.invalidMatch
            isShowingAddMatchSheetAlert = true
            return
        }

        Task{
            do{
                let matchRecord = createMatchRecord()
                let newMatchRecord = try await CloudKitManager.shared.save(record: matchRecord)

                //TIP: Reloads view, locally adds player until another network call is made
                matches.append(TUMatch(record: newMatchRecord))
                matches.sort(by: {$0.matchStartTime < $1.matchStartTime})
                isShowingSheet = false
            } catch {
                alertItem = AlertContext.unableToCreateMatch
                isShowingAddMatchSheetAlert = true
            }
        }
    }

    /// Adds reference of event to TUPlayer record and saves it in cloudkit. Appens it locally and makes a network call to update UI
    /// - Parameter playerManager: Global state object to handle app user's profile
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

                let newPlayerRecord = try await CloudKitManager.shared.save(record: playerRecord)

                playerManager.playerProfile = TUPlayer(record: newPlayerRecord)
                playersInEvent.append(TUPlayer(record: newPlayerRecord))
                playersInEvent = playersInEvent.sorted(by: {$0.firstName < $1.firstName})
            } catch {
                //MARK: Unable to add you to event
                alertItem = AlertContext.unableToAddSelectedPlayersToEvent
                isShowingEventDetailViewAlert = true
            }
        }
    }

    /// Updates TUPlayer record to remove reference
    /// - Parameter playerManager: Global state object to handle app user's profile
    func leaveEvent(with playerManager: PlayerManager){
        Task {
            do {
                let playerRecord = try await CloudKitManager.shared.fetchRecord(with: playerManager.playerProfile!.id)

                var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                if !references.isEmpty{
                    references.removeAll(where: {$0.recordID == event.id})
                    playerRecord[TUPlayer.kInEvents] = references
                }

                let newPlayerRecord = try await CloudKitManager.shared.save(record: playerRecord)
                playerManager.playerProfile = TUPlayer(record: newPlayerRecord)
                playersInEvent.removeAll(where: {$0.id == newPlayerRecord.recordID})
            } catch {
                //MARK: Unable to add leave event
                alertItem = AlertContext.unableToAddSelectedPlayersToEvent
                isShowingEventDetailViewAlert = true
            }
        }
    }

    /// For event owners to search players and manually add them to their event
    /// Updates TUPlayer record's inEvents field to append a reference to the event
    func addCheckedPlayersToEvent(){
        Task {
            do {
                for player in checkedOffPlayers {
                    //Fetches player record
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)
                    
                    //Gets inEvents reference list
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as? [CKRecord.Reference] ?? []

                    //Checks if array is empty, meaning theyre not part of an event
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
                isShowingEventDetailViewAlert = true
            }
        }
    }

    /// Updates event record to set isPublished to true
    /// - Parameter eventsManager: Global state object to handle events
    func publishEvent(eventsManager: EventsManager){
        if event.eventStartDate < Date() {
            alertItem = AlertContext.eventPastStartTime
            isShowingEventDetailViewAlert = true
        } else {
            Task {
                do {
                    let eventRecord = try await CloudKitManager.shared.fetchRecord(with: event.id)
                    eventRecord[TUEvent.kIsPublished] = 1
                    let _ = try await CloudKitManager.shared.save(record: eventRecord)
                    isShowingPublishedButton = false
                } catch {
                    alertItem = AlertContext.unableToPublishEvent
                    isShowingEventDetailViewAlert = true
                }
            }
        }
    }

    /// Fetches matches from cloudkit using event id
    private func getMatchesForEvent(){
        Task {
            do {
                let loadingMatches =  try await CloudKitManager.shared.getMatches(for: event.id)
                matches = loadingMatches
            } catch{
                alertItem = AlertContext.unableToGetMatchesForEvent
                isShowingEventDetailViewAlert = true
            }
        }
    }

    /// Fetches list of players in an event from cloudkit by using the event id
    private func getPlayersInEvents(){
        Task {
            do {
                let loadingPlayers = try await CloudKitManager.shared.getPlayersForEvent(for: event.id)
                playersInEvent = loadingPlayers
            } catch{
                alertItem = AlertContext.unableToGetPlayersForEvent
                isShowingEventDetailViewAlert = true
            }
        }
    }

    /// Fetches list of players that match search string passed by user
    /// - Parameter searchString: User inputted string used to find players
    func getSearchedPlayers(with searchString: String) {
        Task {
            do {
                availablePlayers =  try await CloudKitManager.shared.getPlayers(with: searchString)
            } catch {
                alertItem = AlertContext.unableToSearchForPlayers
                isShowingEventDetailViewAlert = true
            }
        }
    }
    
    /// Removes player from an event
    /// - Parameter player: Player to be removed
    func removePlayerFromEventWith(for player: TUPlayer){
            Task {
                do {
                    //Fetches player record
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)

                    //Removes event reference from player InEvents list
                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == event.id})
                    playerRecord[TUPlayer.kInEvents] = references

                    //Fetches teams in an event
                    let teamsInEvents = try await CloudKitManager.shared.getTeamsFromEvent(for: event.id)

                    //Fetches list of teams the player is on
                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []

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
                    isShowingEventDetailViewAlert = true
                }
            }
    }
}
