//
//  EventsListViewModel.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import CloudKit
import SwiftUI
//MainActor exists so you dont have to do Dispatch.Main.async{}
@MainActor final class EventsListViewModel: ObservableObject {

    @Published var onAppearHasFired          = false
    @Published var isPresentingAddEvent      = false
    @Published var isShowingAlert            = false

    @Published var alertItem: AlertItem      = AlertItem(alertTitle: Text("Unable To Show Alert"),alertMessage: Text("There was a problem showing the alert."))

}
