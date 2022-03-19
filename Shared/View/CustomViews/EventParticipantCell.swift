//
//  EventParticipantCell.swift
//  TeamUp
//
//  Created by Noé Duran on 3/18/22.
//

import SwiftUI

struct EventParticipantCell: View {
    
    @EnvironmentObject var manager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel
    

    var player: TUPlayer
    var playerProfile: TUPlayerGameProfile? {
        return manager.playerProfiles[player.id]?.first(where: {$0.gameName == viewModel.event.eventGame})
    }

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    if let playerProfile = playerProfile {
                        Text(playerProfile.gameID)
                            .bold()
                            .font(.title2)
                        Text("(\(player.firstName))")
                            .bold()
                            .font(.title2)
                    } else {
                        Text("\(player.firstName) \(player.lastName)")
                            .bold()
                            .font(.title2)
                    }
                }
                if let playerProfile = playerProfile {
                    Text(playerProfile.gameRank)
                        .fontWeight(.light)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 65)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
