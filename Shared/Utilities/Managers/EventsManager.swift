//
//  EventsManager.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import Foundation

final class EventsManager: ObservableObject {
    @Published var events: [TUEvent] = []
}
