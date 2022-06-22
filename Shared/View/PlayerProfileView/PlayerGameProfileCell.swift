//
//  PlayerGameProfileCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerGameProfileCell: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel

    @Environment(\.editMode) var editMode

    var gameProfile: TUPlayerGameProfile

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: 205, height: 180)
            .foregroundColor(.appCell)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4){
                    HStack {
                        Text(gameProfile.gameName)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .foregroundColor(Color.appCell)
                            .bold()
                            .font(.title3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        //Adjust based on amount of events
                            .background(Color.getGameColor(gameName: gameProfile.gameName))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .padding(.trailing, 8)
                            .foregroundColor(.blue)
                    }
                    VStack(alignment: .leading) {
                        Text(gameProfile.gameID)
                            .bold()
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.35)
                        Text(gameProfile.gameRank)
                    }
                    .padding(.leading, 8)
                }
            }
    }
}

struct PlayerGameProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfileCell(viewModel: PlayerProfileViewModel(), gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
