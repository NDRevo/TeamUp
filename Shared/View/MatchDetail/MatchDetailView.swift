//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

//MARK: MatchDetailView
//INFO: View that displays teams for the match, you can shuffle and balance the teams, and add players from the list of participants
//INFO: You can only have two teams per match and can shuffle/balance once there are two teams
struct MatchDetailView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventDetailViewModel: EventDetailViewModel
    @StateObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    init(match: TUMatch, event: TUEvent){ _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match, event: event)) }

    var body: some View {
    
        VStack(spacing: appCellSpacing){
                VStack(spacing: 0) {
                    MatchTimeHeader(matchTime: viewModel.match.matchStartTime)
                    HStack {
                        Button(action: {
                            viewModel.shufflePlayers()
                        }, label: {
                            Text("Shuffle")
                                .frame(maxWidth: .infinity)
                        })
                        .modifier(MatchDetailButtonStyle(color: .yellow))
                        
                        Spacer()
                        Button(action: {
                         
                        }, label: {
                            Text("Balance")
                                .frame(maxWidth: .infinity)
                        })
                        .modifier(MatchDetailButtonStyle(color: .blue))
                    }
                    .padding(.bottom, appCellPadding)
                    .padding(.horizontal, appCellPadding)
                    //Make sure it works
                    .disabled(!(viewModel.isAbleToChangeTeams(for: playerManager.playerProfile) && viewModel.event.isArchived == 0))
                }
                .background(Color.appCell)
                .clipShape(RoundedRectangle(cornerRadius: appCornerRadius))
                .padding(.horizontal, appHorizontalViewPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: appCellSpacing) {
                        ForEach(viewModel.teams) { team in
                            VStack(spacing: 0){
                                TeamHeaderView(viewModel: viewModel, team: team)
                                PlayerListForTeam(viewModel: viewModel, team: team)
                            }
                        }
                    }
                    .padding(.horizontal, appHorizontalViewPadding)
                }
                .refreshable {
                    viewModel.getTeamsForMatch()
                }
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.match.matchName)
        .task {
            viewModel.getTeamsForMatch()
        }
        .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    if viewModel.isAbleToAddTeam(for: playerManager.playerProfile) && viewModel.event.isArchived == 0{
                        Button {
                            viewModel.isShowingAddTeam = true
                            viewModel.resetInput()
                        } label: {
                            TeamIcon(color: .blue, isAdding: true)
                                .font(.system(size: 18, weight: .semibold, design: .default))
                        }
                    }
                    if viewModel.isEventOwner(for: playerManager.playerProfile) && viewModel.event.isArchived == 0{
                        Menu {
                            Button(role: .destructive) {
                                viewModel.isShowingConfirmationDialogue = true
                            } label: {
                                Text("Delete Match")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddTeam) {
            NavigationView {
                AddTeamSheet(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.isShowingAddPlayer) {
            NavigationView {
                AddEventPlayerSheet(viewModel: viewModel)
            }
        }
        .confirmationDialog("Delete Match?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                viewModel.deleteMatch()
                eventDetailViewModel.matches.removeAll(where: {$0.id == viewModel.match.id})
                dismiss()
            } label: { Text("Delete") }
        }, message: { Text("Do you want to delete the match? You won't be able to recover it.")}
        )
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event))
            .environmentObject(PlayerManager( playerProfile: TUPlayer(record: MockData.player)))
            .environmentObject(EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}

struct MatchTimeHeader: View {
    var matchTime: Date

    var body: some View {
        HStack(alignment: .center){
            HStack(spacing: imageTextSpacing){
                Image(systemName: "clock")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Match Start Time")
                    .font(.system(.callout, design: .monospaced, weight: .medium))
            }
            Spacer()
            HStack{
                Text(matchTime.convertDateToString())
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(appMinimumScaleFactor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(width: 100)
            }
            .background {
                RoundedRectangle(cornerRadius: appCornerRadius)
                    .foregroundColor(.appBackground)
            }
        }
        .padding(appCellPadding)
    }
}
