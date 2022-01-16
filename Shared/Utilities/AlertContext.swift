//
//  AlertContext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/16/22.
//

import Foundation
import SwiftUI

struct AlertItem {
    var alertDesc: Text
    var button: Button<Text>

}

struct AlertContext {
    
    //MARK: - EventsListView
    
    static let unableToCreateEvent          = AlertItem(alertDesc: Text("Unable to create event.\n Try again later."), button:
                                                            Button.init("Ok", role: .none, action: {}))

    static let unableToRetrieveEvents       = AlertItem(alertDesc: Text("Unable to retrieve events.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))

    static let unableToDeleteEvent          = AlertItem(alertDesc: Text("Unable to delete event.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    //MARK: - EventsDetailView
    
    static let unableToCreateMatch          = AlertItem(alertDesc: Text("Unable to create match.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetMatchesForEvent   = AlertItem(alertDesc: Text("Unable to get matches for event.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToDeleteMatch          = AlertItem(alertDesc: Text("Unable to delete match.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    //MARK: - PlayersListView
    
    static let unableToCreatePlayer         = AlertItem(alertDesc: Text("Unable to create player.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetPlayerList        = AlertItem(alertDesc: Text("Unable to get the list of players.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToDeletePlayer         = AlertItem(alertDesc: Text("Unable to delete player.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    //MARK: - MatchDetailView
    
    static let unableToCreateTeam           = AlertItem(alertDesc: Text("Unable to create team.\n Check your internet connection and try again."), button:
                                                            Button.init("Ok", role: .none, action: {}))
    
    static let unableToDeleteTeam           = AlertItem(alertDesc: Text("Unable to delete team.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
    
    static let unableToGetTeamsForMatch     = AlertItem(alertDesc: Text("Unable to get teams for match.\n Check your internet connection and try again."),
                                                        button: Button.init("Ok", role: .none, action: {}))
}
