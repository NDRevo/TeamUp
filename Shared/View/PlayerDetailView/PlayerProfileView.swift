//
//  PlayerProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/23/22.
//

import SwiftUI

struct PlayerProfileView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel

    @Environment(\.editMode) var editMode
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Game Profiles")
                .bold()
                .font(.title2)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            ScrollView {
                Spacer(minLength: 12)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),spacing: 25) {
                    ForEach(viewModel.playerProfiles) { gameProfile in
                        PlayerGameProfileCell(viewModel: viewModel, gameProfile: gameProfile)
                            .onLongPressGesture {
                                withAnimation {
                                    editMode?.wrappedValue = .active
                                }
                            }
                            .confirmationDialog("Delete Profile?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
                                Button(role: .destructive) {
                                    viewModel.deleteGameProfile(for: gameProfile.id, eventsManager: eventsManager)
                                } label: {
                                    Text("Delete")
                                }
                            }, message: {
                                Text("Do you want to delete the profile?")
                            })
                    }
                    AddGameProfileCell()
                        .onTapGesture {
                            viewModel.isPresentingSheet = true
                            editMode?.wrappedValue = .inactive
                            viewModel.resetInput()
                        }
                }
            }
            .padding(.horizontal, 6)
        }
        .navigationTitle(viewModel.player.firstName)
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .task { viewModel.getPlayersAndProfiles(for: eventsManager) }
        .sheet(isPresented: $viewModel.isPresentingSheet) {
            NavigationView {
                AddPlayerGameProfileSheet(viewModel: viewModel)
            }
        }
        .toolbar { if !viewModel.playerProfiles.isEmpty { EditButton() } }
        .onDisappear { editMode?.wrappedValue = .inactive }
    }
}

struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileView(viewModel: PlayerProfileViewModel(player: TUPlayer(record: MockData.player)))
    }
}

struct AddGameProfileCell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 7)
            .overlay(alignment: .center){
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            .frame(width: 170, height: 110)
    }
}
