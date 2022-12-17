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
        if let players = viewModel.teamsAndPlayer[team.id] {

            LazyVStack(spacing: 0) {
                if !players.isEmpty {
                    ForEach(players){ player in
                        TeamParticipantCell(event: viewModel.event, player: player)
                            .onLongPressGesture {
                                if viewModel.isEventOwner(for: playerManager.playerProfile) && viewModel.event.isArchived == 0 {
                                    viewModel.removePlayerFromTeam(player: player, teamRecordID: team.id)
                                }
                            }
                        if players.last != player {
                            Divider()
                        }
                    }
                } else {
                    VStack(spacing: appImageToTextEmptyContentSpacing){
                        Text("Add players to team")
                            .font(.system(.headline, design: .monospaced, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(appCellPadding*2)
                }
            }
            .background {
                Rectangle()
                    .foregroundColor(.appCell)
                    .cornerRadius(appCornerRadius, corners: [.bottomLeft,.bottomRight])
            }

        } else {
            VStack(spacing: appImageToTextEmptyContentSpacing){
                Text("Add players to team")
                    .font(.system(.headline, design: .monospaced, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(appCellPadding*2)
        }
    }
}

struct PlayerListForTeam_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListForTeam(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)), team: TUTeam(record: MockData.team))
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
