//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {
    
    var event: TUEvent
    @StateObject var viewModel = EventDetailViewModel()

    var body: some View {
            VStack {
                List {
                    Section(header: Text("Matches")) {
                        ForEach(viewModel.matches) { match in
                            NavigationLink(destination: MatchDetailView(match: match)) {
                                VStack(alignment: .leading){
                                    Text(match.name)
                                    Text(match.startTime.convertDateToString())
                                        .font(.caption)
                                }
                            }
                        }
                        .onDelete { index in
                           //Delete Match
                        }
                        Button {
                            viewModel.isShowingAddMatch = true
                        } label: {
                            Text("Add Match")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $viewModel.isShowingAddMatch) {
                            NavigationView{
                                AddMatchSheet(matches: $viewModel.matches)
                                    .toolbar { Button("Dismiss") { viewModel.isShowingAddMatch = false } }
                                    .navigationTitle("Create Match")
                            }
                        }
                    }

                    Section(header: Text("Players")) {
                        ForEach(viewModel.players, id: \.self){ player in
                            Text(player.name)
                        }
                        .onDelete { index in
                            //Remove Player
                        }
                        Button {
                            viewModel.isShowingAddPlayerToEvent = true
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $viewModel.isShowingAddPlayerToEvent) {
                            NavigationView{
                                AddExistingPlayer(players: $viewModel.players)
                                    .toolbar { Button("Dismiss") { viewModel.isShowingAddPlayerToEvent = false } }
                                    .navigationTitle("Add Player")
                            }
                        }
                    }
                

                    Section(header: Text("Admins")) {
                        ForEach(MockData.Matches) { match in
                                Text(match.name)
                        }
                        .onDelete { index in
                            //Remove Admin
                        }
                        Button {
                            viewModel.isShowingAddAdmin = true
                        } label: {
                            Text("Add Admin")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $viewModel.isShowingAddAdmin) {
                            NavigationView{
                                AddAdminSheet()
                                    .toolbar { Button("Dismiss") { viewModel.isShowingAddAdmin = false } }
                                    .navigationTitle("Add Admin")
                            }
                        }
                    }
                }
                .toolbar {
                    EditButton()
                }
                
            }
            .navigationTitle(event.eventName)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: TUEvent(date: Date(), name: "Event", game: Games.VALORANT))
    }
}
