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
        RoundedRectangle(cornerRadius: 8)
            .frame(height: 100)
            .foregroundColor(.appCell)
            .overlay(alignment: .center) {
                HStack(spacing: 12){
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 80,height: 80)
                        .foregroundColor(.appBackground)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(playerManager.playerProfile!.username)")
                            .font(.title)
                            .bold()
                        Text("\(playerManager.playerProfile!.firstName) \(playerManager.playerProfile!.lastName)")
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, 12)
    }
}

struct ProfileNameBar_Previews: PreviewProvider {
    static var previews: some View {
        ProfileNameBar()
    }
}
