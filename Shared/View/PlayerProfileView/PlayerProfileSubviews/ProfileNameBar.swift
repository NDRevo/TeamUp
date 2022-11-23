//
//  ProfileNameBar.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

//MARK: ProfileNameBar
//INFO: Displays username and first and last name of player
struct ProfileNameBar: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        HStack(spacing: 12){
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 75,height: 75)
                .foregroundColor(.blue)
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 75)
                .foregroundColor(.appCell)
                .overlay(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if let playerProfile = playerManager.playerProfile {
                                Text("@\(playerProfile.username)")
                                    .font(.title)
                                    .bold()
                                Text("\(playerProfile.firstName) \(playerProfile.lastName)")
                                    .font(.title2)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
        }
        .padding(.horizontal, 12)
    }
}

struct ProfileNameBar_Previews: PreviewProvider {
    static var previews: some View {
        ProfileNameBar()
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
