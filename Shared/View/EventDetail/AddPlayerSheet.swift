//
//  AddPlayerSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddPlayerSheet: View {
    
    var eventGame: Games
    @Binding var players: [String]
    @ObservedObject var viewModel: EventDetailViewModel
    @State var playerName: String = ""
    @State var gameID: String = ""
    @State var playerRank: TUPlayerGameDetails = TUPlayerGameDetails(game: .VALORANT, gameID: "Revo#0010", rank: "Immortal")
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            TextField("Player Name", text: $playerName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            TextField("Game ID", text: $gameID)
                .disableAutocorrection(true)
                .keyboardType(.twitter)
                .textInputAutocapitalization(.never)
            Picker("Rank", selection: $playerRank) {
                ForEach(viewModel.getRanksForGame(game: eventGame), id: \.self){ rank in
                    Text(rank)
                }
            }
            .pickerStyle(.menu)
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
        AddPlayerSheet(eventGame: .VALORANT, players: .constant([]), viewModel: EventDetailViewModel())
    }
}
