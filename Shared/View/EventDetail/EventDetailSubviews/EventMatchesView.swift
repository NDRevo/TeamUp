//
//  EventMatchesView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventMatchesView
//INFO: Displays a horizontal scroll view of EventMatchCells below the Matches title. Tapping on the cell leads to MatchDetailView
struct EventMatchesView: View {

    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Matches")
                    .font(.title2)
                    .bold()
                Spacer()
                if viewModel.isEventOwner(for: playerManager.playerProfile?.record) && viewModel.event.isArchived == 0 {
                    Button {
                        viewModel.sheetToPresent = .addMatch
                        viewModel.resetMatchInput()
                    } label: {
                        Image(systemName: "rectangle.badge.plus")
                            .font(.system(size: 24, design: .default))
                    }
                }
            }
            .padding(.horizontal, 12)
            
            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.matches.isEmpty {
                HStack{
                    Spacer()
                    Text("No matches found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                    Spacer()
                }
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(viewModel.matches) { match in
                            NavigationLink {
                                MatchDetailView(viewModel: MatchDetailViewModel(match: match, event: viewModel.event))
                                    .environmentObject(viewModel)
                                    .onDisappear {
                                        viewModel.refreshEventDetails()
                                    }
                            } label: {
                                EventMatchCellView(matchName: match.matchName, matchTime: match.matchStartTime.convertDateToString())
                            }
                            .buttonStyle(PlainButtonStyle()) //Removes blue highlight from MatchCell
                        }
                    }
                    .offset(x: 12) //Shifts start position of cells to the right 16pt
                    .padding(.trailing, 24) //Makes last cell not cut off
                }
            }
        }
    }
}
