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
        if playerManager.playerSchool != Constants.none || playerManager.isGameLeader {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if playerManager.playerSchool != Constants.none {
                        HStack{
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                            Text(playerManager.playerSchool)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    if playerManager.isGameLeader {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                            Text("Rutgers VALORANT Club")
                                .font(.title3)
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
