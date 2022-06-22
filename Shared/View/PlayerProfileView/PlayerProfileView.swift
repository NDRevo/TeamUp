//
//  PlayerProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerProfileView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @StateObject var viewModel = PlayerProfileViewModel()

    @Environment(\.editMode) var editMode

    var body: some View {
        NavigationView{
            if !viewModel.isLoggedIn() {
                CreateProfileView(viewModel: viewModel)
            } else {
                ScrollView {
                    VStack(alignment: .leading){
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 100)
                            .foregroundColor(.appCell)
                            .overlay(alignment: .center) {
                                HStack(spacing: 12){
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 80,height: 80)
                                        .foregroundColor(.appBackground)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(viewModel.playerFirstName) \(viewModel.playerLastName)")
                                            .font(.title)
                                            .bold()
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        HStack {
                            Text("Game Profiles")
                                .bold()
                                .font(.title2)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                            Button {
                                viewModel.isPresentingSheet = true
                                editMode?.wrappedValue = .inactive
                                viewModel.resetInput()
                            } label: {
                                Image(systemName: "plus.rectangle.portrait")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:20)
                            }
                        }
                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .top, spacing: 10) {
                                ForEach(viewModel.playerGameProfiles) { gameProfile in
                                    PlayerGameProfileCell(viewModel: viewModel, gameProfile: gameProfile)
                                        .onLongPressGesture {
                                            viewModel.deleteGameProfile(for: gameProfile.id, eventsManager: eventsManager)
                                        }
                                }
                            }
                        }
                        .frame(height: viewModel.playerGameProfiles.isEmpty ? 20 : 180)
                        .scrollIndicators(.hidden)
                        
                        VStack{
                            HStack {
                                Text("Events Participating")
                                    .bold()
                                    .font(.title2)
                                    .accessibilityAddTraits(.isHeader)
                                Spacer()
                            }
                            LazyVStack(alignment: .center){
                                ForEach(viewModel.eventsParticipating) { event in
                                    EventListCell(event: event)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 12)
                .navigationTitle("Profile")
                .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                    viewModel.alertItem.alertMessage
                })
                .sheet(isPresented: $viewModel.isPresentingSheet) {
                    NavigationView {
                        AddPlayerGameProfileSheet(viewModel: viewModel)
                    }
                }
                .onDisappear { editMode?.wrappedValue = .inactive }
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
