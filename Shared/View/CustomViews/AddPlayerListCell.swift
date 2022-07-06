//
//  PlayerListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/16/22.
//

import SwiftUI

struct AddPlayerListCell: View {

    @EnvironmentObject var manager: EventsManager
    @Binding var checkedOffPlayers: [TUPlayer]
    var eventGame: String

    @State var isChecked = false
    var player: TUPlayer
    var playerProfile: TUPlayerGameProfile? {
        return manager.playerProfiles[player.id]?.first(where: {$0.gameName == eventGame})
    }

    @Environment(\.dismissSearch) var dismissSearch

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    if let playerProfile = playerProfile {
                        Text(playerProfile.gameID)
                            .bold()
                            .font(.title2)
                        Text("(\(player.firstName))")
                            .bold()
                            .font(.title2)
                    } else {
                        Text("\(player.firstName) \(player.lastName)")
                            .bold()
                            .font(.title2)
                    }
                }
                if let playerProfile = playerProfile {
                    Text(playerProfile.gameRank)
                        .fontWeight(.light)
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
