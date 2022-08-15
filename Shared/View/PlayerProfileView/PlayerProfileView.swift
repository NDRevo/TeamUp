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

    @EnvironmentObject var eventsManager: EventsManager
    @StateObject var viewModel = PlayerProfileViewModel()

    var body: some View {
        NavigationView{
            if !viewModel.isLoggedIn() {
                CreateProfileView(viewModel: viewModel)
            } else {
                ScrollView {
                    VStack(alignment: .leading){
                        ProfileNameBar(viewModel: viewModel)
                        PlayerGameProfilesList(viewModel: viewModel)
                        ParticipatingInEventsList(viewModel: viewModel)
                    }
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Profile")
                .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                    viewModel.alertItem.alertMessage
                })
                .sheet(isPresented: $viewModel.isPresentingSheet) {
                    NavigationView {
                        AddPlayerGameProfileSheet(viewModel: viewModel)
                    }
                    .presentationDetents([.fraction(0.60)])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }

                    }
                }
                .refreshable {
                    do {
                        eventsManager.userProfile = try await CloudKitManager.shared.getUserRecord()
                    } catch {}
                }
                .background(Color.appBackground)
            }
        }
        .task {
            viewModel.getProfile()
            viewModel.getEventsParticipating()
        }
    }
}

struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileView(viewModel: PlayerProfileViewModel())
    }
}

//MARK: ProfileNameBar
//INFO: Displays username and first and last name of player
struct ProfileNameBar: View {
    @ObservedObject var viewModel: PlayerProfileViewModel

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
                        Text("\(viewModel.playerUsername)")
                            .font(.title)
                            .bold()
                        Text("\(viewModel.playerFirstName) \(viewModel.playerLastName)")
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
    @ObservedObject var viewModel: PlayerProfileViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Events Participating")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            
            if !viewModel.eventsParticipating.isEmpty {
                LazyVStack(alignment: .center, spacing: 12){
                    ForEach(viewModel.eventsParticipating) { event in
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
    @ObservedObject var viewModel: PlayerProfileViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Game Profiles")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    viewModel.isPresentingSheet = true
                    viewModel.resetInput()
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
                    ForEach(viewModel.playerGameProfiles) { gameProfile in
                        PlayerGameProfileCell(viewModel: viewModel, gameProfile: gameProfile)
                            .sheet(isPresented: $viewModel.isEditingGameProfile){
                                NavigationView {
                                    EditGameProfileView(viewModel: viewModel, gameProfile: viewModel.tappedGameProfile!)
                                }
                                .presentationDetents([.fraction(0.75)])
                            }
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: viewModel.playerGameProfiles.isEmpty ? 20 : 180)
        }
    }
}
