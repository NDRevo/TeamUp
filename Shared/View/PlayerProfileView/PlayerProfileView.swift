//
//  PlayerProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

//MARK: PlayerProfileView
//INFO: Displays players name, game profiles, and events they're participating in
struct PlayerProfileView: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        NavigationView{
            if playerManager.iCloudRecord == nil { NoiCloudView() }
            else if playerManager.playerProfile == nil { CreateProfileView() }
            else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12){
                        ProfileNameBar()
                        PlayerInfoBar()
                        PlayerGameProfilesList()
                        ParticipatingInEventsList()
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .sheet(isPresented: $playerManager.isPresentingSheet) {
                    NavigationView { AddPlayerGameProfileSheet() }
                    .presentationDetents([.fraction(0.60)])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                playerManager.isEditingProfile.toggle()
                            }
                        } label: {
                            Image(systemName: "person.crop.circle.dashed")
                                .foregroundColor(playerManager.isEditingProfile ? .gray : .blue)
                        }
                    }
                    if playerManager.isEditingProfile {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                Task{await playerManager.saveEditedProfile()}
                            } label: {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .foregroundStyle(.green, .blue)
                            }
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink { SettingsView() }
                            label: {
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                }
                .refreshable {
                    if !playerManager.isEditingProfile {
                        await playerManager.getRecordAndPlayerProfile()
                    }
                }
                .background(Color.appBackground)
            }
        }
    }
}

struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileView()
            .environmentObject(PlayerManager(
                iCloudRecord: MockData.player,
                playerProfile: TUPlayer(record: MockData.player)))
    }
}
