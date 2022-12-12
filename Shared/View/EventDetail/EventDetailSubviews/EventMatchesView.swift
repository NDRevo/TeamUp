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
        VStack(alignment: .leading, spacing: appCellSpacing){
            HStack {
                Text("Matches")
                    .font(.system(.title2, design: .rounded, weight: .bold))
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
            .padding(.horizontal, appHorizontalViewPadding)

            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.matches.isEmpty {
                HStack{
                    Spacer()
                    Text("No matches found")
                        .font(.system(.headline, design: .monospaced, weight: .medium))
                        .foregroundColor(.secondary)
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
                                EventMatchCellView(viewModel: viewModel, match: match)
                            }
                            .buttonStyle(PlainButtonStyle()) //Removes blue highlight from MatchCell
                        }
                    }
                    .offset(x: 4) //Shifts start position of cells to the right 12pt
                    .padding(.trailing, 24) //Makes last cell not cut off
                }
            }
        }
    }
}

struct EventMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        EventMatchesView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
