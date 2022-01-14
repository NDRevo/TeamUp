//
//  AddPlayerSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddPlayerSheet: View {
    
    @State var playerName: String = ""
    @Binding var players: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            TextField("Player Name", text: $playerName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            Section{
                Button {
                    players.append(playerName)
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerSheet(players: .constant([]))
    }
}
