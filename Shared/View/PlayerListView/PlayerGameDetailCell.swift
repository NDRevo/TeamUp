//
//  PlayerGameDetailCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerGameDetailCell: View {
    
    var gameDetail: TUPlayerGameDetails
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 6)
                .overlay(alignment: .leading){
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(gameDetail.gameName)")
                            .font(.title3)
                            .bold()
                            .minimumScaleFactor(0.75)
                        Text("\(gameDetail.gameID)")
                        Text("\(gameDetail.gameRank)")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
                .frame(width: 170, height: 170)
        }
    }
}

struct PlayerGameDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameDetailCell(gameDetail: TUPlayerGameDetails(record: MockData.playerGameDetail))
    }
}
