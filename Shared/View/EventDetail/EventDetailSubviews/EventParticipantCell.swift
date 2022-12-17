//
//  EventParticipantCell.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 12/16/22.
//

import SwiftUI

struct EventParticipantCell: View {

    var event: TUEvent
    var player: TUPlayer
    @State var gameProfile: TUPlayerGameProfile? = nil

    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 0){
                if let gameProfile = gameProfile {
                    Text("\(gameProfile.gameID)")
                        .font(.system(.headline, design: .rounded, weight: .medium))
                    Text(gameProfile.gameRank)
                } else {
                    Text("\(player.username)")
                        .font(.system(.headline, design: .rounded, weight: .medium))
                }
            }
            .padding(.vertical, appCellPadding)
            Spacer()
        }
        .padding(.horizontal, appHorizontalViewPadding)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: appCornerRadius))
        .task {
            do{
                gameProfile = try await CloudKitManager.shared.getPlayerGameProfile(for: player,event: event)
            } catch {
                print(error)
            }
        }
    }
}

struct EventParticipantCell_Previews: PreviewProvider {
    static var previews: some View {
        EventParticipantCell(event: TUEvent(record: MockData.event), player: TUPlayer(record: MockData.player))
    }
}
