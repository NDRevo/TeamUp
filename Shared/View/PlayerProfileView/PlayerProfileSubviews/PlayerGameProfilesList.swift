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
        VStack(alignment: .center, spacing: appCellSpacing) {
            HStack {
                Text("Game Profiles")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    playerManager.isPresentingSheet.toggle()
                    playerManager.resetGameProfileInput()
                } label: {
                    Image(systemName: "person.crop.rectangle.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.primary, .secondary)
                }
            }
            .padding(.horizontal, appHorizontalViewPadding)
            if playerManager.playerGameProfiles.isEmpty {
                VStack(alignment: .center, spacing: appImageToTextEmptyContentSpacing){
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: appImageSizeEmptyContent))
                        .foregroundColor(.secondary)
                    Text("No game profiles found")
                        .font(.system(.headline, design: .monospaced, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(appCellPadding)
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
                    .padding(.horizontal, appHorizontalViewPadding)
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
