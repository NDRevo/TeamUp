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
                .frame(width: 80,height: playerManager.isEditingProfile ? 130 : 80)
                .foregroundColor(.blue)
            RoundedRectangle(cornerRadius: 8)
                .frame(height: playerManager.isEditingProfile ? 130 : 80)
                .foregroundColor(.appCell)
                .overlay(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if let playerProfile = playerManager.playerProfile {
                                if playerManager.isEditingProfile {
                                    TextField(playerProfile.username, text: $playerManager.editedUsername)
                                        .font(.title)
                                        .bold()
                                        .keyboardType(.twitter)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .minimumScaleFactor(0.75)
                                        .padding(.horizontal, 4)
                                } else {
                                    Text("@\(playerProfile.username)")
                                        .font(.title)
                                        .bold()
                                }
                                
                                if playerManager.isEditingProfile {
                                    VStack(spacing: 6) {
                                        TextField(playerProfile.firstName, text: $playerManager.editedFirstName)
                                            .padding(4)
                                            .background { Color.appBackground.cornerRadius(8) }
                                            .autocorrectionDisabled()
                                        TextField(playerProfile.lastName, text: $playerManager.editedLastName)
                                            .padding(4)
                                            .background { Color.appBackground.cornerRadius(8) }
                                            .autocorrectionDisabled()
                                    }
                                    .font(.title2)
                                    .minimumScaleFactor(0.75)
                                } else {
                                    Text("\(playerProfile.firstName) \(playerProfile.lastName)")
                                        .font(.title2)
                                        .minimumScaleFactor(0.75)
                                }
                            }
                        }
                        if !playerManager.isEditingProfile { Spacer() }
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
