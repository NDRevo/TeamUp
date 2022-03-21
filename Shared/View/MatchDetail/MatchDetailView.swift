//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {

    @EnvironmentObject var eventDetailManager: EventDetailManager
    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack{
                    if viewModel.isAbleToChangeTeams(){
                        MatchOptionButtons(viewModel: viewModel)
                    }
                    
                    ForEach(viewModel.teams) { team in
                        VStack{
                            HStack {
                                Text(team.teamName)
                                    .font(.title)
                                Spacer()
                                HStack(spacing: 24){
                                    if viewModel.isEventOwner() {
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
                            PlayerListForTeam(viewModel: viewModel, team: team)
                        }
                        .padding()
                    }
                }
            }
            if viewModel.isLoading{LoadingView()}
        }
        .background(Color.appBackground)
        .sheet(isPresented: $viewModel.isShowingAddPlayer) {
            NavigationView{
                AddEventPlayerSheet(viewModel: viewModel)
            }
        }
        .navigationTitle(viewModel.match.matchName)
        .task {
            viewModel.getTeamsForMatch()
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    Button {
                        viewModel.getTeamsForMatch()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    if viewModel.isAbleToAddTeam(){
                        Button {
                            viewModel.isShowingAddTeam = true
                            viewModel.resetInput()
                        } label: {
                            TeamIcon(color: .blue, isAdding: true)
                                .font(.system(size: 18, weight: .semibold, design: .default))
                        }
                    }
                    if viewModel.isEventOwner(){
                        Menu {
                            Button(role: .destructive) {
                                viewModel.isShowingConfirmationDialogue = true
                            } label: {
                                Text("Delete Match")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddTeam) {
            NavigationView{
                AddTeamSheet(viewModel: viewModel)
            }
        }
        .confirmationDialog("Delete Match?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                viewModel.deleteMatch()
                eventDetailManager.matches.removeAll(where: {$0.id == viewModel.match.id})
                dismiss()
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("Do you want to delete the match? You won't be able to recover it.")
        })
    }
}

//struct MatchDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MatchDetailView(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: []))
//    }
//}

struct PlayerListForTeam: View {
    
    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam
    
    var body: some View {
        ForEach(viewModel.teamsAndPlayer[team.id] ?? []){ player in
            EventParticipantCell(eventGame: viewModel.event.eventGame, player: player)
            .swipeActions(edge: .trailing) {
                if viewModel.isEventOwner() {
                    Button(role: .destructive){
                        viewModel.removePlayerFromTeam(player: player, teamRecordID: team.id)
                    } label: {
                        Label("Remove Player", systemImage: "minus.circle.fill")
                    }
                }
            }
        }
    }
}

struct MatchOptionButtons: View {
    
    @ObservedObject var viewModel: MatchDetailViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                viewModel.shufflePlayers()
            }, label: {
                Text("Shuffle")
            })
            .modifier(MatchDetailButtonStyle(color: .yellow))

            Button(action: {
                print("BALANCE")
            }, label: {
                Text("Balance")
            })
            .modifier(MatchDetailButtonStyle(color: .blue))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
    }
}
