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
                .font(.system(.title2, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(appMinimumScaleFactor)
            Spacer()
            HStack{
                if  viewModel.event.isArchived == 0 {
                    Button(action: {
                        viewModel.isShowingAddPlayer = true
                        viewModel.selectedTeam = team
                    }, label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(.headline))
                            .frame(height: 14)
                           
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.regular)
                    .headerProminence(.increased)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    
                    Button(action: {
                        viewModel.deleteTeam(teamID: team.id)
                    }, label: {
                        Image(systemName: "minus")
                            .font(.system(.headline))
                            .frame(height: 14)
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.regular)
                    .headerProminence(.increased)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    
                }
            }
        }
        .padding(appCellPadding)
        .background {
            Rectangle()
                .foregroundColor(.appCell)
                .cornerRadius(appCornerRadius, corners: [.topLeft,.topRight])
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
