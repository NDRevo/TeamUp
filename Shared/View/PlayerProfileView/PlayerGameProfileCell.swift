//
//  PlayerGameProfileCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

//MARK: PlayerGameProfileCell
//INFO: View to display game profile
struct PlayerGameProfileCell: View {

    @EnvironmentObject var playerManager: PlayerManager
    var gameProfile: TUPlayerGameProfile

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: 205, height: 95)
            .foregroundColor(.appCell)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4){
                    HStack(alignment: .top) {
                        VStack(alignment: .leading){
                            Text(gameProfile.gameName + gameProfile.gameVariantName)
                                .foregroundColor(Color.appCell)
                                .fontWeight(.heavy)
                                .font(.body)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.getGameColor(gameName: gameProfile.gameName))
                                }
                            VStack(alignment: .leading) {
                                Text(gameProfile.gameID)
                                    .bold()
                                    .font(.title)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.35)
                                Text(gameProfile.gameRank)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.semibold)
                                .frame(width: 20)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    playerManager.isEditingGameProfile.toggle()
                                    playerManager.tappedGameProfile = gameProfile
                                }
                            Spacer()
                            Image(systemName: "square.on.square.badge.person.crop")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.semibold)
                                .frame(width: 22)
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .padding(9)
                }
            }
    }
}

struct PlayerGameProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfileCell(gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
