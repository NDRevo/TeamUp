//
//  SettingsView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var playerManager: PlayerManager
    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        List {
            Section {
                if playerManager.playerProfile!.isVerifiedStudent == 0 {
                    Button {
                        Task{
                            viewModel.isShowingWebsite = true
                        }
                    } label: {
                        Text("Verify Student")
                    }
                }
            }

            Section {
                if playerManager.isRequestingGameLeader {
                    Text("Game Leader Request Pending")
                        .foregroundColor(.gray)
                } else if playerManager.isGameLeader {
                    Button(role: .destructive) {
                        viewModel.checkCanRemoveRole(eventsManager.myPublishedEvents)
                        Task{
                           await eventsManager.deleteAllUnpublishedEvents()
                        }
                    } label: {
                        Text("Remove Game Leader Role")
                    }
                } else {
                    Button {
                        Task {
                            await viewModel.changeGameLeaderPosition(to: 2, handledBy: playerManager)
                        }
                    } label: {
                        Text("Request Game Leader")
                    }
                    .disabled(playerManager.isRequestingGameLeader)
                }
            } footer: {
                if playerManager.isGameLeader {
                    HStack(alignment: .center){
                        Spacer()
                            Text("Verified \(playerManager.playerProfile!.inSchool) Student")
                        Spacer()
                    }
                    .onTapGesture {
                        viewModel.hasVerified = false
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingWebsite) {
            NavigationView {
                WebKitView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.isShowingWebsite = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
            }
        }
        .confirmationDialog("Remove Game Leader Role?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                Task {
                    await viewModel.changeGameLeaderPosition(to: 0, handledBy: playerManager)
                }
            } label: { Text("Remove role") }
        }, message: { Text("Removing game leader role will retain archived events but delete unpublished events, are you sure?")}
        )
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
