//
//  PlayerListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/16/22.
//

import SwiftUI

//MARK: AddPlayerListCell
//INFO: View that displays players name and game profile details with circle to checkmark within search
struct AddPlayerListCell: View {

    @Binding var checkedOffPlayers: [TUPlayer]
    var eventGame: String
    var player: TUPlayer
    //MARK: Grab playerprofile when fetching players
    var playerProfile: TUPlayerGameProfile?

    @State var isChecked = false

    @Environment(\.dismissSearch) var dismissSearch

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("\(player.username)")
                    .bold()
                    .font(.title3)
                Text("\(player.firstName) \(player.lastName)")
                    .font(.body)
            }
            Spacer()
            Image(systemName: isChecked ? "checkmark.circle" : "circle")
                .font(.system(size: 20))
                .frame(width: 45, height: 45)
                .foregroundColor(.blue)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissSearch()
            isChecked.toggle()
            if isChecked {
                checkedOffPlayers.append(player)
            } else {
                checkedOffPlayers.removeAll(where: {player.id == $0.id})
            }
        }
    }
}
