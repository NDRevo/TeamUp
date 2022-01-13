//
//  MatchDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct MatchDetailView: View {
    var body: some View {
        VStack{
            
            List {
                Section {
                    Text("Mick")
                    Text("Anthony")
                    Text("Quanton")
                    Text("John")
                    Text("Alice")
                    Button {
                        
                    } label: {
                        Text("Add Player")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Team 1")
                        .bold()
                        .font(.subheadline)
                }

                Section {
                    Text("Mick")
                    Text("Anthony")
                    Text("Quanton")
                    Text("John")
                    Text("Alice")
                    Button {
                        
                    } label: {
                        Text("Add Player")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Team 2")
                        .bold()
                        .font(.subheadline)
                }
                
                Button(role: .destructive) {
                    //Delete
                } label: {
                    Text("Delete Match")
                        .bold()
                }

            }
            


        }
        .navigationTitle("Immortal")
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView()
    }
}
