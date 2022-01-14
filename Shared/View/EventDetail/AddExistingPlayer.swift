//
//  AddExistingPlayer.swift
//  TeamUp
//
//  Created by Noé Duran on 1/14/22.
//

import SwiftUI

struct AddExistingPlayer: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    @State var selectedPlayer: TUPlayer = TUPlayer(name: "Bob")
    @Binding var players: [TUPlayer]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        List{
            Picker("Player", selection: $selectedPlayer) {
                ForEach(eventsManager.players, id: \.self){ player in
                    Text(player.name)
                }
            }
            .pickerStyle(.inline)
            
            Section{
                Button {
                    players.append(selectedPlayer)
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddExistingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AddExistingPlayer(players: .constant([]))
    }
}
