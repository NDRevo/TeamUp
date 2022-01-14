//
//  AddPlayerInEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventPlayer: View {

    @Binding var players: [TUPlayer]
    @State var playerName: String = ""

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            TextField("Player Name", text: $playerName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            Section{
                Button {
                    //Add player to match/team
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddEventPlayer_Previews: PreviewProvider {
    static var previews: some View {
        AddEventPlayer(players: .constant([]))
    }
}
