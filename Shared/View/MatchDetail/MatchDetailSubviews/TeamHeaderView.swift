//
//  TeamHeaderView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

struct TeamHeaderView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventDetailViewModel: EventDetailViewModel
    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam

    var body: some View {
        HStack {
            Text(team.teamName)
                .font(.title)
            Spacer()
            HStack(spacing: 24){
                if viewModel.isEventOwner(for: playerManager.playerProfile) && viewModel.event.isArchived == 0 {
                    Button {
                        viewModel.isShowingAddPlayer = true
                        viewModel.selectedTeam = team
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 24, design: .default))
                    }
                    Button {
                        viewModel.deleteTeam(teamID: team.id)
                    } label: {
                        TeamIcon(color: .red, isAdding: false)
                            .font(.system(size: 25, weight: .regular, design: .default))
                    }
                }
            }
        }
    }
}
