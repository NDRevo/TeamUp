//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {
    
    var event: TUEvent
    @State var isShowingAddMatch = false
    @State var isShowingAddPlayer = false
    @State var isShowingAddAdmin = false
    
    @State var players: [String] = ["John", "Mick", "David"]
    @State var matches: [TUMatch] = [TUMatch(date: Date(), name: "Immortal"),TUMatch(date: Date(), name: "Diamond"),TUMatch(date: Date(), name: "Randoms")]

    var body: some View {
            VStack {
                List {
                    Section(header: Text("Matches")) {
                        ForEach(matches) { match in
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
                            isShowingAddMatch = true
                        } label: {
                            Text("Add Match")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $isShowingAddMatch) {
                            NavigationView{
                                AddMatchSheet(matches: $matches)
                                    .toolbar { Button("Dismiss") { isShowingAddMatch = false } }
                                    .navigationTitle("Create Match")
                            }
                        }
                    }

                    Section(header: Text("Players")) {
                        ForEach(players, id: \.self){ player in
                            Text(player)
                        }
                        .onDelete { index in
                            //Remove Player
                        }
                        Button {
                            isShowingAddPlayer = true
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $isShowingAddPlayer) {
                            NavigationView{
                                AddPlayerSheet(players: $players)
                                    .toolbar { Button("Dismiss") { isShowingAddPlayer = false } }
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
                            isShowingAddAdmin = true
                        } label: {
                            Text("Add Admin")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $isShowingAddAdmin) {
                            NavigationView{
                                AddAdminSheet()
                                    .toolbar { Button("Dismiss") { isShowingAddAdmin = false } }
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
