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
    @EnvironmentObject var eventsManager: EventsManager

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
                .alert(playerManager.alertItem.alertTitle, isPresented: $playerManager.isShowingAlert, actions: {}, message: {
                    playerManager.alertItem.alertMessage
                })
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
    }
}

//MARK: ProfileNameBar
//INFO: Displays username and first and last name of player
struct ProfileNameBar: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(height: 100)
            .foregroundColor(.appCell)
            .overlay(alignment: .center) {
                HStack(spacing: 12){
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 80,height: 80)
                        .foregroundColor(.appBackground)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(playerManager.playerProfile!.username)")
                            .font(.title)
                            .bold()
                        Text("\(playerManager.playerProfile!.firstName) \(playerManager.playerProfile!.lastName)")
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, 12)
    }
}

//MARK: ParticipatingInEventsList
//INFO: Displays list of events player is participating in shown via a verticle stack view below a Events Participating header
struct ParticipatingInEventsList: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        VStack {
            HStack {
                Text("Events Participating")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }

            if !playerManager.eventsParticipating.isEmpty {
                LazyVStack(alignment: .center, spacing: 12){
                    ForEach(playerManager.eventsParticipating) { event in
                        EventListCell(event: event)
                    }
                }
                .padding(.bottom, 12)
            } else {
                VStack(alignment: .center, spacing: 12){
                    Image(systemName: "rectangle.dashed")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("You're not part of any events")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .offset(y: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}

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

struct NoiCloudView: View {
    var body: some View {
        VStack(spacing: 25){
            Image(systemName: "bolt.horizontal.icloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 45)
            Text("Sign into iCloud to create and use a TeamUp account")
                .bold()
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
