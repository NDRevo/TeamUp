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
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }

            if !playerManager.eventsParticipating.isEmpty {
                LazyVStack(alignment: .center, spacing: 12){
                    ForEach(playerManager.eventsParticipating) { event in
                        EventListCell(event: event)
                    }
                }
                .padding(.bottom, 12)
            } else {
                VStack(alignment: .center, spacing: 12){
                    Image(systemName: "rectangle.dashed")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("You're not part of any events")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .offset(y: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}

struct ParticipatingInEventsList_Previews: PreviewProvider {
    static var previews: some View {
        ParticipatingInEventsList()
            .environmentObject(PlayerManager())
    }
}
