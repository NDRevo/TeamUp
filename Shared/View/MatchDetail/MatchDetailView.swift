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
    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack{
                    if viewModel.isAbleToChangeTeams(for: playerManager.playerProfile) && viewModel.event.isArchived == 0{
                        MatchOptionButtons(viewModel: viewModel)
                    }

                    ForEach(viewModel.teams) { team in
                        VStack{
                            TeamHeaderView(viewModel: viewModel, team: team)
                            PlayerListForTeam(viewModel: viewModel, team: team)
                        }
                        .padding(12)
                    }
                }
                if viewModel.isLoading{LoadingView()}
            }
        }
        //FIX: This fails to show refresh indicator but still refreshes??
        .refreshable {
            viewModel.getTeamsForMatch()
        }
        .background(Color.appBackground)
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
        MatchDetailView(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)))
    }
}
