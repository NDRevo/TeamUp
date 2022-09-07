//
//  EventParticipantCell.swift
//  TeamUp
//
//  Created by Noé Duran on 3/18/22.
//

import SwiftUI

//MARK: EventParticipantCell
//INFO: View that displays players name and game profile details
struct EventParticipantCell: View {

    var event: TUEvent
    var player: TUPlayer
    @State var gameProfile: TUPlayerGameProfile? = nil

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                if let gameProfile = gameProfile {
                    Text("\(gameProfile.gameID)")
                        .bold()
                        .font(.title3)
                    Text(gameProfile.gameRank)
                } else {
                    Text("\(player.username)")
                        .bold()
                        .font(.title)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 65)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task {
            do{
                gameProfile = try await CloudKitManager.shared.getPlayerGameProfile(for: player,event: event)
            } catch {
                print(error)
            }
        }
    }
}
