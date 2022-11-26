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
            if let playerProfile =  playerManager.playerProfile {
                if playerProfile.inSchool != WordConstants.none {
                    Section {
                        if !playerManager.isVerifiedStudent {
                            Button {
                                Task{
                                    viewModel.isShowingWebsite = true
                                }
                            } label: {
                                Label("Verify School Attendance", systemImage: "graduationcap.fill")
                            }
                        }
                        if playerManager.isClubLeader == .requestClubLeader {
                            Label("Club Leader Request Pending", systemImage: "person.badge.clock.fill")
                                .foregroundColor(.gray)
                        }
                        else if playerManager.isClubLeader == .clubLeader {
                            Button(role: .destructive) {
                                viewModel.checkCanRemoveRole(eventsManager.myPublishedEvents)
                                Task{
                                    await eventsManager.deleteAllUnpublishedEvents()
                                }
                            } label: {
                                Text("Remove Club Leader Role")
                            }
                        }
                        else if playerManager.isClubLeader == .deniedClubLeader {
                            Label {
                                Text("Denied Club Leader Role")
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "person.fill.xmark")
                                    .foregroundStyle(.red)
                            }
                        }
                        else {
                            Button {
                                viewModel.isShowingRequestClubLeaderSheet = true
                            } label: {
                                Label("Request Club Leader",systemImage: "person.badge.shield.checkmark.fill")
                            }
                            .disabled(playerManager.isClubLeader == .requestClubLeader)
                        }
                    } footer: {
                        if playerManager.isVerifiedStudent {
                            HStack(alignment: .center){
                                Text("Verified \(playerProfile.inSchool) Student")
                            }
                        }
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
        .sheet(isPresented: $viewModel.isShowingRequestClubLeaderSheet) {
            RequestClubLeaderSheet(viewModel: viewModel)
        }
        .confirmationDialog("Remove Game Leader Role?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                Task {
                    await viewModel.changeClubLeaderPosition(to: 0, handledBy: playerManager)
                }
            } label: { Text("Remove role") }
        }, message: { Text("Removing game leader role will retain archived events but delete unpublished events, are you sure?")}
        )
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
