//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {
    
    var match: TUMatch
    @State var players = [TUPlayer(name: "John", rank: ["VALORANT" : "Diamond"]),TUPlayer(name: "Luke", rank: ["VALORANT" : "Diamond"]),TUPlayer(name: "Mick", rank: ["VALORANT" : "Diamond"]),TUPlayer(name: "Justin", rank: ["VALORANT" : "Diamond"]),TUPlayer(name: "Jack", rank: ["VALORANT" : "Diamond"])]
    
    @State var isShowingAddPlayer = false
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
                
                
                Section {
                    ForEach(players){ player in
                        Text(player.name)
                    }
                    .onDelete(perform: { indexSet in
                        print("Hello")
                    })
                    Button {
                        isShowingAddPlayer = true
                    } label: {
                        Text("Add Player")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isShowingAddPlayer) {
                        NavigationView{
                            AddPlayerInEventSheet(players: $players)
                                .toolbar { Button("Dismiss") { isShowingAddPlayer = false } }
                                .navigationTitle("Add Player")
                        }
                    }
                } header: {
                    Text("Team 1")
                        .bold()
                        .font(.subheadline)
                }
                
                Section {
                    Button {
                        //Delete
                    } label: {
                        Text("Add Team")
                    }
                }
            }
            .toolbar {
                EditButton()
            }
        }
        .navigationTitle(match.name)
    }
    
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: TUMatch(date: Date(), name: "Match"))
    }
}
