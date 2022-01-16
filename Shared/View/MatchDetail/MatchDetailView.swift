//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {
    
    @ObservedObject var viewModel: MatchDetailViewModel
    
    //Players that are in events, retrieved by finding players that have reference to the event id 
    @State var players: [TUPlayer] = []
    
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
                        ForEach(players){ player in
                            Text(player.firstName)
                        }
 
                        Button {
                            viewModel.isShowingAddPlayer = true
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                        Button(role: .destructive) {
                            viewModel.deleteTeam(recordID: team.id)
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
        .task {
            viewModel.getTeamsForMatch()
        }
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $viewModel.isShowingAddPlayer) {
            NavigationView{
                AddEventPlayer(players: $players)
                    .toolbar { Button("Dismiss") { viewModel.isShowingAddPlayer = false } }
                    .navigationTitle("Add Player")
            }
        }
        .navigationTitle(viewModel.match.matchName)
    }
    
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match)))
    }
}
