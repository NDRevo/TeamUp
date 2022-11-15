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
                    VStack(alignment: .leading){
                        ProfileNameBar()
                        PlayerGameProfilesList()
                        ParticipatingInEventsList()
                    }
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Profile")
                .sheet(isPresented: $playerManager.isPresentingSheet) {
                    NavigationView { AddPlayerGameProfileSheet() }
                    .presentationDetents([.fraction(0.60)])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink { SettingsView() }
                        label: { Image(systemName: "gearshape.fill") }
                    }
                }
                .refreshable { await playerManager.getRecordAndPlayerProfile()}
                .background(Color.appBackground)
            }
        }
        .task {
            playerManager.getEventsParticipating()
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
