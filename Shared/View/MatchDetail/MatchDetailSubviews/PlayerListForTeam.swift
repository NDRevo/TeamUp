//
//  PlayerListForTeam.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

struct PlayerListForTeam: View {
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam

    var body: some View {
        ForEach(viewModel.teamsAndPlayer[team.id] ?? []){ player in
            EventParticipantCell(event: viewModel.event, player: player)
                .onLongPressGesture {
                    if viewModel.isEventOwner(for: playerManager.playerProfile) && viewModel.event.isArchived == 0 {
                        viewModel.removePlayerFromTeam(player: player, teamRecordID: team.id)
                    }
                }
        }
    }
}
