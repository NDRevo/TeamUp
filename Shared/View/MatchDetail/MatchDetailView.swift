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

    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack {
            VStack{
                List {
                    if viewModel.isAbleToChangeTeams(){
                        MatchOptionButtons(viewModel: viewModel)
                    }

                    ForEach(viewModel.teams) { team in
                        Section {
                            PlayerListForTeam(viewModel: viewModel, team: team)

                            if viewModel.isEventOwner(){
                                TeamButtons(viewModel: viewModel, team: team)
                            }
                        } header: {
                            Text(team.teamName)
                                .bold()
                                .font(.subheadline)
                        }
                    }
                    if viewModel.isAbleToAddTeam(){
                        Section {
                            Button {
                                viewModel.isShowingAddTeam = true
                                viewModel.resetInput()
                            } label: {
                                Text("Add Team")
                            }
                            .sheet(isPresented: $viewModel.isShowingAddTeam) {
                                NavigationView{
                                    AddTeamSheet(viewModel: viewModel)
                                }
                            }
                        }
                    }
                }
            }
            if viewModel.isLoading{LoadingView()}
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
                Button {
                    viewModel.getTeamsForMatch()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
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
        .confirmationDialog("Delete Match?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                viewModel.deleteMatch()
                eventDetailManager.matches.removeAll(where: {$0.id == viewModel.match.id})
                presentation.wrappedValue.dismiss()
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


struct TeamButtons: View {
    
    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam
    
    var body: some View {
        Button {
            viewModel.isShowingAddPlayer = true
        } label: {
            Text("Add Player")
                .foregroundColor(.blue)
        }
        .sheet(isPresented: $viewModel.isShowingAddPlayer) {
            NavigationView{
                AddEventPlayerSheet(viewModel: viewModel, team: team)
            }
        }
        Button(role: .destructive) {
            viewModel.deleteTeam(teamID: team.id)
        } label: {
            Text("Delete Team")
        }
    }
}

struct PlayerListForTeam: View {
    
    @ObservedObject var viewModel: MatchDetailViewModel
    var team: TUTeam
    
    var body: some View {
        ForEach(viewModel.teamsAndPlayer[team.id] ?? []){ player in
            HStack{
                VStack(alignment: .leading){
                    Text(player.firstName)
                        .bold()
                        .font(.title2)
                }
            }
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
