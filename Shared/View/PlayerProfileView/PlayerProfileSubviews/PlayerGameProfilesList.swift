//
//  SwiftUIView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

//MARK: PlayerGameProfilesList
//INFO: Displays list of game profiles in a horizontal scroll view below a Game Profiles header
struct PlayerGameProfilesList: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack {
                Text("Game Profiles")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    playerManager.isPresentingSheet.toggle()
                    playerManager.resetGameProfileInput()
                } label: {
                    Image(systemName: "person.crop.rectangle.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(playerManager.isEditingProfile ? .secondary : .primary, .secondary)
                        .frame(width: 30)
                }
                .disabled(playerManager.isEditingProfile)
            }
            .padding(.horizontal, 12)
            if playerManager.playerGameProfiles.isEmpty {
                VStack(alignment: .center, spacing: 12){
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No game profiles found")
                        .foregroundColor(.secondary)
                        .bold()
                }
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 10) {
                        ForEach(playerManager.playerGameProfiles) { gameProfile in
                            PlayerGameProfileCell(gameProfile: gameProfile)
                                .sheet(isPresented: $playerManager.isEditingGameProfile){
                                    NavigationView {
                                        EditGameProfileView(gameProfile: playerManager.tappedGameProfile!)
                                    }
                                    .presentationDetents([.fraction(0.75)])
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
    }
}

struct PlayerGameProfilesList_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfilesList()
            .environmentObject(PlayerManager())
    }
}
