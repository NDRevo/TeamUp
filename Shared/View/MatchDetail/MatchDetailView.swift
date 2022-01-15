//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {
    
    var match: TUMatch
    
    //Players that are in events, retrieved by finding players that have reference to the event id 
    @State var players: [TUPlayer] = []
    
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
                        Text(player.firstName)
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
                            AddEventPlayer(players: $players)
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
        .navigationTitle(match.matchName)
    }
    
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(match: TUMatch(record: MockData.match))
    }
}
