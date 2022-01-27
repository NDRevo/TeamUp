//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {

    @ObservedObject var viewModel: MatchDetailViewModel

    var body: some View {
        VStack{
            List {
                HStack(spacing: 20) {
                    Button(action: {
                        //Something
                    }, label: {
                        Text("Shuffle")
                    })
                    .modifier(MatchDetailButtonStyle(color: .yellow))
    
                    Button(action: {
                        //Something
                    }, label: {
                        Text("Balance")
                    })
                    .modifier(MatchDetailButtonStyle(color: .blue))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
                
                ForEach(viewModel.teams) { team in
                    Section {
                        ForEach(viewModel.teamsAndPlayer[team.id] ?? []){ player in
                            HStack{
                                VStack(alignment: .leading){
                                    Text(player.firstName)
                                        .bold()
                                        .font(.title2)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.removePlayerFromTeam(indexSet: indexSet, teamID: team.id)
                        }

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
                    } header: {
                        Text(team.teamName)
                            .bold()
                            .font(.subheadline)
                    }
                }
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
        .navigationTitle(viewModel.match.matchName)
        .task {
            viewModel.getTeamsForMatch()
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .toolbar {
            if viewModel.teamsAndPlayer.values.contains(where: {$0 != []}){
                EditButton()
            }
        }
    }
}

//struct MatchDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MatchDetailView(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), playersInEvent: []))
//    }
//}
