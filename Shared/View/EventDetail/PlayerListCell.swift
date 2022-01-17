//
//  PlayerListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/16/22.
//

import SwiftUI

struct PlayerListCell: View {
    
    @EnvironmentObject var manager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    var player: TUPlayer
    @State var isChecked = false
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(player.firstName)
                    .bold()
                    .font(.title2)
                //Handle Later: Multiple games
                if let player = manager.playerDetails[player.id] {
                    Text(player[0].gameID)
                        .font(.callout)
                }
            }
            Spacer()
            Image(systemName: isChecked ? "checkmark.circle" : "circle")
                .font(.system(size: 20))
                .frame(width: 45, height: 45)
                .foregroundColor(.blue)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isChecked.toggle()
            if isChecked {
                viewModel.checkedOffPlayers.append(player)
            } else {
                viewModel.checkedOffPlayers.removeAll(where: {player.id == $0.id})
            }
        }
    }
}
