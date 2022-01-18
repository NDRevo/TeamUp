//
//  ExistingPlayerListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/17/22.
//

import SwiftUI

struct ExistingPlayerListCell: View {

    @ObservedObject var viewModel: MatchDetailViewModel

    var player: TUPlayer
    @State var isChecked = false
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(player.firstName)
                    .bold()
                    .font(.title2)
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
