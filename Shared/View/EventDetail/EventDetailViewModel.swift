//
//  EventDetailViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import CloudKit
import SwiftUI

enum PresentingSheet {
    case addMatch, addPlayer, addAdmin
}

@MainActor final class EventDetailViewModel: ObservableObject {

    var event: TUEvent

    init(event: TUEvent){
        self.event = event
        matchDate = event.eventDate
    }

    @Published var checkedOffPlayers: [TUPlayer]    = []
    @Published var availablePlayers: [TUPlayer]     = []
    @Published var searchedPlayers: [TUPlayer]      = []

    @Published var playersInEvent: [TUPlayer]       = []
    @Published var matches: [TUMatch]               = []

    @Published var matchName: String                = ""
    @Published var matchDate: Date                  = Date()
    @Published var onAppearHasFired                 = false

    @Published var isShowingConfirmationDialogue    = false
    @Published var isLoading                        = false
    @Published var isShowingSheet                   = false
    @Published var sheetToPresent: PresentingSheet? {
        didSet{
            isShowingSheet = true
        }
    }

    @Published var isShowingAlert: Bool             = false
    @Published var alertItem: AlertItem             = AlertItem(alertTitle: Text("Unable To Show Alert"),
                                                                alertMessage: Text("There was a problem showing the alert."))
    @Environment(\.dismiss) var dismiss

    func isEventOwner() -> Bool {
        return event.eventOwner.recordID == CloudKitManager.shared.userRecord?.recordID
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

    func refreshEventDetails(){
        getMatchesForEvent()
        getPlayersInEvents()
    }

    func setUpEventDetails(){
        //Prevents from running twice
        if !onAppearHasFired {
            getMatchesForEvent()
            getPlayersInEvents()
            onAppearHasFired = true
        }
    }

    @ViewBuilder func presentSheet() -> some View {
        switch sheetToPresent {
            case .addMatch:
                AddMatchSheet(viewModel: self)
            case .addPlayer:
                AddExistingPlayerSheet(viewModel: self)
            case .addAdmin:
                AddAdminSheet()
            case .none:
                EmptyView()
        }
    }

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
                matches.sort(by: {$0.matchStartTime < $1.matchStartTime})
            } catch {
                alertItem = AlertContext.unableToCreateMatch
                isShowingAlert = true
            }
        }
    }

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
        Task {
            do {
                let eventRecord = try await CloudKitManager.shared.fetchRecord(with: event.id)
                eventRecord[TUEvent.kIsPublished] = 1
                let _ = try await CloudKitManager.shared.save(record: eventRecord)

            } catch {
                //Unable to publish evvent
                isShowingAlert = true
            }
        }
    }

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

    func getAvailablePlayers(from players: [TUPlayer]){

        checkedOffPlayers = []
        availablePlayers = []

        for player in players {
            if !playersInEvent.contains(where: {$0.id == player.id}){
                availablePlayers.append(player)
            }
        }
    }

    func getSearchedPlayers(with searchString: String) {
        Task {
            do {
                availablePlayers =  try await CloudKitManager.shared.getPlayers(with: searchString)
            } catch {
                print(error)
                //Unable to search for players
            }
        }
    }

    func removePlayerFromEventWith(for player: TUPlayer){
            Task {
                do {
                    let playerRecord = try await CloudKitManager.shared.fetchRecord(with: player.id)

                    var references: [CKRecord.Reference] = playerRecord[TUPlayer.kInEvents] as! [CKRecord.Reference]
                    references.removeAll(where: {$0.recordID == event.id})

                    playerRecord[TUPlayer.kInEvents] = references

                    let teamsInEvents = try await CloudKitManager.shared.getTeamsFromEvent(for: event.id)

                    var teamReferences: [CKRecord.Reference] = playerRecord[TUPlayer.kOnTeams] as? [CKRecord.Reference] ?? []

                    if !teamsInEvents.isEmpty {
                        for teamReference in teamReferences {
                            //If team doesnt exist then remove from player's onTeams
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

    private func showLoadingView(){
        isLoading = true
    }

    private func hideLoadingView(){
        isLoading = false
    }
}
