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
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.appCell)
                .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 7)
                .overlay(alignment: .top){
                    Rectangle()
                        .fill(Color.getGameColor(gameName: gameProfile.gameName).gradient)
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                        .frame(height: 45)
                        .overlay(alignment: .center){
                            Text("\(gameProfile.gameName)")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                        }
                }
                .overlay(alignment: .topTrailing){
                    if editMode?.wrappedValue == .active{
                        Button(role: .destructive) {
                            viewModel.isShowingConfirmationDialogue = true
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .renderingMode(.original)
                        }
                        .font(.system(size: 24, weight: .regular, design: .default))
                        .offset(x: 9, y: -12)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("ID:")
                                .bold()
                                .font(.subheadline)
                            Text("\(gameProfile.gameID)")
                                .font(.callout)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .textSelection(.enabled)
                            Spacer()
                        }
                        HStack {
                            Text("Rank:")
                                .bold()
                                .font(.subheadline)
                            Text("\(gameProfile.gameRank)")
                                .font(.callout)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    .frame(width: 155, height: 60)
                    .padding(.horizontal, 8)
                }
                .frame(width: 170, height: 110)
        }
    }
}

struct PlayerGameProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfileCell(viewModel: PlayerProfileViewModel(), gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
