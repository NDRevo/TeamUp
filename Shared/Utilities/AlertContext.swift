//
//  AlertContext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/16/22.
//

import Foundation
import SwiftUI

struct AlertItem {
    var alertTitle: Text
    var alertMessage: Text
    var button: Button<Text>?
}

struct AlertContext {
    //MARK: - EventsListView

    static let invalidEvent                     = AlertItem(alertTitle: Text("Invalid Event"),
                                                        alertMessage: Text("Event must have a title, location, and start date past now."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToCreateEvent              = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to create event. Try again later."),
                                                        button:Button.init("Ok", role: .none, action: {}))

    static let unableToRetrieveEvents           = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to retrieve events.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToDeleteEvent              = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to delete event.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToGetUserRecord            = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to get your user record.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetUserProfile           = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to retrieve your profile.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToRemovePlayersFromEvent   = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to remove players from event.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToRemovePlayerFromEvent   = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to remove player from event.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    //MARK: - EventsDetailView

    static let unableToAccessCalendar            = AlertItem(alertTitle: Text("Calendar Access"),
                                                             alertMessage: Text("Unable to access calendar. Make sure you give calendar access to this app."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let invalidMatch                      = AlertItem(alertTitle: Text("Invalid Match"),
                                                             alertMessage: Text("Match must have a title and starte date past event."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToCreateMatch               = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to create match.\n Check your internet connection and try again."),
                                                             button:Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetMatchesForEvent        = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to get matches for event.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetPlayersForEvent        = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to get event players.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToAddSelectedPlayersToEvent = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to add selected players.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToDeleteMatch               = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to delete match.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))

    static let unableToPublishEvent              = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to publish event.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))
    
    static let eventPastStartTime                = AlertItem(alertTitle: Text("Event Error"),
                                                             alertMessage: Text("Unable to publish event.\n Current time is past event start time."),
                                                             button: Button.init("Ok", role: .none, action: {}))

    static let unableToSearchForPlayers          = AlertItem(alertTitle: Text("Server Error"),
                                                             alertMessage: Text("Unable to search for players.\n Check your internet connection and try again."),
                                                             button: Button.init("Ok", role: .none, action: {}))

    //MARK: - PlayersListView

    static let invalidPlayer                = AlertItem(alertTitle: Text("Invalid Player"),
                                                        alertMessage: Text("You must fill out all player details."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToCreatePlayer         = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to create player.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToGetPlayerList        = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to get the list of players.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToDeletePlayer         = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to delete player.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    //MARK: - PlayerProfileView

    static let invalidUsername              = AlertItem(alertTitle: Text("Invalid Username"),
                                                        alertMessage: Text("Username already exists. Try something more unique!"),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let emptyNamePlayerProfile       = AlertItem(alertTitle: Text("Invalid Username"),
                                                        alertMessage: Text("First and last name must be filled out."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let invalidGameProfile           = AlertItem(alertTitle: Text("Invalid Game Profile"),
                                                        alertMessage: Text("A game profile must have an ID."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToSaveGameProfile      = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to save game profile. \n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToDeleteGameProfile    = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to delete game profile. \n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToCheckIfValidPlayer        = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to get verify your profile.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    static let unableToFetchEventsParticipating  = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to get list of events participating.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetUserGameProfiles       = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Unable to retrieve your game profiles.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    static let failedToDeleteProfile             = AlertItem(alertTitle: Text("Server Error"),
                                                        alertMessage: Text("Failed to delete profile.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))

    //MARK: - MatchDetailView

    static let invalidTeam                      = AlertItem(alertTitle: Text("Invalid Team"),
                                                            alertMessage: Text("Team must have a name."),
                                                            button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToCreateTeam               = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to create team.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToDeleteTeam               = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to delete team.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetTeamsForMatch         = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to get teams for match.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))

    static let unableToShuffleTeams             = AlertItem(alertTitle: Text("Shuffle Error"),
                                                            alertMessage: Text("Unable to shuffle teams.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))

    static let unableToAddSelectedPlayersToTeam = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to add selected players.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToFindPlayerToRemove       = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to find the player to delete.\n Refresh the app and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))

    static let unableToRemovePlayerFromTeam     = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Unable to delete player from team.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))
    //MARK: - SettingsView
    
    static let unableToChangeGameLeaderPosition     = AlertItem(alertTitle: Text("Server Error"),
                                                            alertMessage: Text("Failed to make game leader.\n Check your internet connection and try again."),
                                                            button: Button.init("Ok", role: .none, action: {}))

    static let unableToRemoveGameLeaderRole         = AlertItem(alertTitle: Text("Can't Remove Role"),
                                                            alertMessage: Text("Remove your published events before removing game leader role."),
                                                            button: Button.init("Ok", role: .none, action: {}))
}
