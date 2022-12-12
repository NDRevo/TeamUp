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
        RoundedRectangle(cornerRadius: appCornerRadius)
            .frame(width: 205, height: 95)
            .foregroundColor(.appCell)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4){
                    HStack(alignment: .top) {
                        VStack(alignment: .leading){
                            Text(gameProfile.gameName + gameProfile.gameVariantName)
                                .foregroundColor(Color.appCell)
                                .font(.system(.body, design: .rounded, weight: .heavy))
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    RoundedRectangle(cornerRadius: appCornerRadius)
                                        .foregroundColor(Color.getGameColor(gameName: gameProfile.gameName))
                                }
                            VStack(alignment: .leading) {
                                Text(gameProfile.gameID)
                                    .font(.system(.title, design: .monospaced, weight: .bold))
                                    .lineLimit(1)
                                    //Have its own minimumscale factor, must be shown at all times
                                    .minimumScaleFactor(0.35)
                                Text(gameProfile.gameRank)
                                    .font(.system(.subheadline, design: .monospaced, weight: .medium))
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "square.and.pencil")
                                .font(.system(.headline, design: .default, weight: .medium))
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    playerManager.isEditingGameProfile.toggle()
                                    playerManager.tappedGameProfile = gameProfile
                                }
                            Spacer()
                            Image(systemName: "square.on.square.badge.person.crop")
                                .font(.system(.headline, design: .default, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .padding(appCellPadding)
                }
            }
    }
}

struct PlayerGameProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfileCell(gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
