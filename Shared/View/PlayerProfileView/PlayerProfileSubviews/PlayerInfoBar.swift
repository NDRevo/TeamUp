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
                            if playerManager.isEditingProfile {
                                Picker("School", selection: $playerManager.editedSelectedSchool) {
                                    ForEach(SchoolLibrary.allCases, id: \.self){school in
                                        Text(school.rawValue)
                                            .tag(school.rawValue.self)
                                    }
                                }
                                .disabled((playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent)
                                .pickerStyle(.menu)
                            } else {
                                if playerManager.playerProfile?.inSchool != WordConstants.none {
                                    Text(playerManager.playerProfile!.inSchool)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                    Spacer()
                                    if playerManager.studentVerifiedStatus == .isVerifiedStudent {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.primary, .secondary)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            Spacer()
                        }
                        if playerManager.isClubLeader == .clubLeader && !playerManager.isEditingProfile{
                            HStack {
                                Image(systemName: "person.badge.shield.checkmark.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                Text(playerManager.playerProfile!.clubLeaderClubName)
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.appCell)
                }
                //Footer
                if playerManager.isEditingProfile && ((playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent) {
                    Text("Remove club and school verification status before changing schools!")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        //We apply another 12pts of padding to have a bit of a inset look
                        .padding(.horizontal, 12)
                }
            }
            .padding(.horizontal,12)
    }
}

struct PlayerInfoBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInfoBar()
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
