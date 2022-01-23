//
//  PlayerProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerProfileView: View {

    var player: TUPlayer
    var playerDetails: [TUPlayerGameDetails]?

    var body: some View {
        VStack(alignment: .leading){
           
            Text("Game Profiles")
                .bold()
                .font(.title2)
                .accessibilityAddTraits(.isHeader)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),spacing: 25) {
                    ForEach(playerDetails ?? []) { detail in
                        PlayerGameDetailCell(gameDetail: detail)
                    }
                    AddGameDetailCell()
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(player.firstName)
    }
}

struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileView(player: TUPlayer(record: MockData.player))
    }
}

struct AddGameDetailCell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 6)
            .overlay(alignment: .center){
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            .frame(width: 170, height: 170)
    }
}
