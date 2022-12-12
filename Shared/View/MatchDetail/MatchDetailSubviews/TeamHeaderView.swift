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
                .font(.system(.title2, design: .rounded, weight: .medium))
                .lineLimit(1)
                //FIX: When adding players, this actives for some reason?
                //.minimumScaleFactor(0.75)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 20){
                if  viewModel.event.isArchived == 0 {
                    Button {
                        viewModel.isShowingAddPlayer = true
                        viewModel.selectedTeam = team
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(.title2, design: .rounded, weight: .regular))
                    }
                    Button(role: .destructive){
                        viewModel.deleteTeam(teamID: team.id)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(.title2, design: .rounded, weight: .regular))
                    }
                }
            }
        }
        .padding(appCellPadding)
        .background {
            RoundedRectangle(cornerRadius: appCornerRadius)
                .foregroundColor(.appCell)
        }
    }
}


struct TeamHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TeamHeaderView(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)), team: TUTeam(record: MockData.team))
            .environmentObject(PlayerManager())
            .environmentObject(EventDetailViewModel(event: TUEvent(record: MockData.event)))
        
    }
}
