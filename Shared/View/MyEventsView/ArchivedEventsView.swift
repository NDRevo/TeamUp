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
            LazyVStack(spacing: appCellSpacing) {
                ForEach(eventsManager.myArchivedEvents){ event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventListCell(event: event)
                    }
                }
            }
            .padding(.horizontal, appHorizontalViewPadding)
        }
        .background { Color.appBackground.edgesIgnoringSafeArea(.all)}
        .onAppear {
            eventsManager.getMyArchivedEvents(for: playerManager.playerProfile)
        }
        .navigationTitle("Archived Events")
    }
    
}

struct ArchivedEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedEventsView()
            .environmentObject(EventsManager())
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
