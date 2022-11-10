//
//  ArchivedEventsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 9/6/22.
//

import SwiftUI

struct ArchivedEventsView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventsManager: EventsManager
    @State var archivedEvents: [TUEvent] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(archivedEvents){ event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventListCell(event: event)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .task {
            do {
                archivedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: false, withSpecificOwner: playerManager.playerProfile, isArchived: true)
            } catch {
                print(error)
            }
        }
        .navigationTitle("Archived Events")
    }
    
}

struct ArchivedEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedEventsView()
    }
}
