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
        if playerManager.isEditingProfile {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                            Picker("School", selection: $playerManager.editedSelectedSchool) {
                                ForEach(SchoolLibrary.allCases, id: \.self){school in
                                    Text(school.rawValue)
                                        .tag(school.rawValue.self)
                                }
                            }
                            .disabled((playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent)
                            .pickerStyle(.menu)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.appCell)
                }
                if (playerManager.isClubLeader == .clubLeader || playerManager.isClubLeader == .requestClubLeader) || playerManager.studentVerifiedStatus == .isVerifiedStudent {
                    Text("Remove club and school verification status before changing schools!")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        //We apply another 12pts of padding to have a bit of a inset look
                        .padding(.horizontal, 12)
                }
            }
            .padding(.horizontal,12)
        } else if playerManager.playerProfile?.inSchool != WordConstants.none || playerManager.isClubLeader == .clubLeader {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if playerManager.playerProfile?.inSchool != WordConstants.none {
                        HStack{
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Text(playerManager.playerProfile!.inSchool)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }
                    if playerManager.isClubLeader == .clubLeader {
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
            .padding(.horizontal,12)
        
        }
    }
}

struct PlayerInfoBar_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInfoBar()
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
