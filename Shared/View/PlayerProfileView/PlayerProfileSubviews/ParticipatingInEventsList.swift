//
//  ParticipatingInEventsList.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

//MARK: ParticipatingInEventsList
//INFO: Displays list of events player is participating in shown via a verticle stack view below a Events Participating header
struct ParticipatingInEventsList: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        VStack {
            HStack {
                Text("Events Participating")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }

            if !playerManager.eventsParticipating.isEmpty {
                LazyVStack(alignment: .center, spacing: appCellSpacing){
                    ForEach(playerManager.eventsParticipating) { event in
                        EventListCell(event: event)
                    }
                }
                .padding(.bottom, 12)
            } else {
                VStack(alignment: .center, spacing: appImageToTextEmptyContentSpacing){
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: appImageSizeEmptyContent))
                        .foregroundStyle(.primary, .secondary)
                    Text("Not part of any events")
                        .font(.system(.headline, design: .monospaced, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .offset(y: 60)
            }
        }
        .padding(.horizontal, appHorizontalViewPadding)
        .onAppear {
            playerManager.getEventsParticipating()
        }
    }
}

struct ParticipatingInEventsList_Previews: PreviewProvider {
    static var previews: some View {
        ParticipatingInEventsList()
            .environmentObject(PlayerManager())
    }
}
