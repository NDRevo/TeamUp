//
//  TeamParticipantCell.swift
//  TeamUp
//
//  Created by Noé Duran on 3/18/22.
//

import SwiftUI

//MARK: TeamParticipantCell
//INFO: View that displays players name and game profile details
struct TeamParticipantCell: View {

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
        .padding(.horizontal, appCellPadding)
        .task {
            do{
                gameProfile = try await CloudKitManager.shared.getPlayerGameProfile(for: player,event: event)
            } catch {
                print(error)
            }
        }
    }
}

struct TeamParticipantCell_Previews: PreviewProvider {
    static var previews: some View {
        TeamParticipantCell(event: TUEvent(record: MockData.event), player: TUPlayer(record: MockData.player))
    }
}
