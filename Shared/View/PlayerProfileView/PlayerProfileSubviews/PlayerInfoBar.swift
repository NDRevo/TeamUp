//
//  PlayerInfoBar.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/23/22.
//

import SwiftUI

struct PlayerInfoBar: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Image(systemName: "graduationcap.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                        Menu {
                            Picker("School", selection: $playerManager.editedSelectedSchool) {
                                ForEach(SchoolLibrary.allCases, id: \.self){school in
                                    Text(school.rawValue)
                                        .tag(school.rawValue.self)
                                }
                            }
                        } label: {
                            HStack {
                                Text(playerManager.playerProfile?.inSchool != WordConstants.none ? playerManager.isEditingProfile ? playerManager.editedSelectedSchool : playerManager.playerProfile!.inSchool : playerManager.editedSelectedSchool)
                                    .font(.system(.body, design: .rounded, weight: .medium))
                                    .foregroundColor(playerManager.isEditingProfile ? playerManager.studentVerifiedStatus == .isVerifiedStudent ? .primary : .blue : .primary)
                                Spacer()
                                if playerManager.studentVerifiedStatus == .isVerifiedStudent {
                                    Image(systemName: "checkmark.seal.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .foregroundStyle(.primary, .secondary)
                                        .foregroundColor(playerManager.profileColor ?? .green)
                                }
                            }
                        }
                        .disabled((playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent || !playerManager.isEditingProfile)
                    }

                    if playerManager.isClubLeader == .clubLeader && !playerManager.isEditingProfile{
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundStyle(playerManager.profileColor ?? .secondary, .primary)
                            Text(playerManager.playerProfile!.clubLeaderClubName)
                                .font(.system(.body, design: .rounded, weight: .medium))
                        }
                    }
                }
                Spacer()
            }
            .padding(appCellPadding)
            .background {
                RoundedRectangle(cornerRadius: appCornerRadius)
                    .foregroundColor(.appCell)
            }
            //Footer
            if playerManager.isEditingProfile && ((playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent) {
                Text("Remove club and school verification status before changing schools!")
                    .foregroundColor(.secondary)
                    .font(.system(.footnote, design: .rounded, weight: .regular))
                //We apply another 12pts of padding to have a bit of a inset look
                    .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, appHorizontalViewPadding)
    }
}

struct PlayerInfoBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInfoBar()
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
