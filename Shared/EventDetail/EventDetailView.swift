//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct Matches {
    var name: String
}

struct EventDetailView: View {
    @State var isCollapsed = false
    
    var matches: [Matches] = [Matches(name: "Immortal"),Matches(name: "Diamond"),Matches(name: "Random")]

    var body: some View {
            VStack {
                List {
                    Section(header: Text("Matches")) {
                        ForEach(matches, id: \.self.name) { match in
                            NavigationLink(destination: MatchDetailView()) {
                                VStack(alignment: .leading){
                                    Text(match.name)
                                    Text("9:00PM")
                                }
                            }
                        }
                        Button {
                            
                        } label: {
                            Text("Add Match")
                                .foregroundColor(.blue)
                        }
                    }

                    Section(header: Text("Players")) {
                        Text("Mick")
                        Text("Bob")
                        Text("John")
                        Button {
                            
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                    }
                

                    Section(header: Text("Admins")) {
                        ForEach(matches, id: \.self.name) { match in
                                Text(match.name)
                        }
                        Button {
                            
                        } label: {
                            Text("Add Admin")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("10 Mans In-Houses")
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView()
    }
}
