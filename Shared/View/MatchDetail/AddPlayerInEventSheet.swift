//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddPlayerInEventSheet: View {
    
    @State var playerName: String = ""
    @Binding var players: [TUPlayer]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            TextField("Player Name", text: $playerName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            Section{
                Button {
                    players.append(TUPlayer(name: playerName))
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddPlayerInEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerInEventSheet(players: .constant([]))
    }
}
