//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI

@MainActor final class EventsListViewModel: ObservableObject {

    @Published var onAppearHasFired             = false
    @Published var currentGameSelected: Game    = Game(name: GameNames.all, ranks: [])

    @Published var isShowingAlert               = false

    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

}
