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
                .bold()
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
                            .font(.title)
                    }
                    Button(role: .destructive){
                        viewModel.deleteTeam(teamID: team.id)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                }
            }
        }
        .padding(.horizontal,15)
        .padding(.vertical,10)
        .background {
            RoundedRectangle(cornerRadius: 10)
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
