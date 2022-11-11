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

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(eventsManager.myArchivedEvents){ event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventListCell(event: event)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            eventsManager.getMyArchivedEvents(for: playerManager.playerProfile)
        }
        .navigationTitle("Archived Events")
    }
    
}

struct ArchivedEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedEventsView()
    }
}
