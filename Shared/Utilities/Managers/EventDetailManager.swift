//
//  EventDetailManager.swift
//  TeamUp
//
//  Created by Noé Duran on 3/18/22.
//

import CloudKit
import SwiftUI

final class EventDetailManager: ObservableObject {
    //Players that join/added to the event from the players list
    @Published var playersInEvent: [TUPlayer]       = []
    @Published var matches: [TUMatch]               = []
}

