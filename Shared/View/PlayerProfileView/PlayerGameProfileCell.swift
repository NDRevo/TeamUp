//
//  PlayerGameProfileCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerGameProfileCell: View {
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
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .padding(.trailing, 8)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                viewModel.isEditingGameProfile.toggle()
                                viewModel.tappedGameProfile = gameProfile
                            }
                    }
                    VStack(alignment: .leading) {
                        Text(gameProfile.gameID)
                            .bold()
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.35)
                        Text(gameProfile.gameRank)
                        Spacer()
                        
                        //TIP: ForEach<Array<String>, String, Optional<Text>>: the ID  occurs multiple times within the collection, this will give undefined results!
                        //This will be resolved when made an optional
                        ForEach(gameProfile.gameAliases, id: \.self){ alias in
                            if alias != "" {
                                Text(alias)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6) //Matches top padding of game title rectangle (8-2 = 6)
                }
            }
    }
}

struct PlayerGameProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfileCell(viewModel: PlayerProfileViewModel(), gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
