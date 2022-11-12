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
        VStack {
            HStack {
                Text("Game Profiles")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    playerManager.isPresentingSheet.toggle()
                    playerManager.resetInput()
                } label: {
                    Image(systemName: "plus.rectangle.portrait")
                        .resizable()
                        .scaledToFit()
                        .frame(width:20)
                }
            }
            .padding(.horizontal, 12)

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
            .frame(height: playerManager.playerGameProfiles.isEmpty ? 20 : 180)
        }
    }
}

struct PlayerGameProfilesList_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGameProfilesList()
    }
}
