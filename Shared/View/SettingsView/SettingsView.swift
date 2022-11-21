//
//  SettingsView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var playerManager: PlayerManager
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
                if viewModel.isRequestingGameLeader {
                    Text("Game Leader Request Pending")
                        .foregroundColor(.gray)
                } else if playerManager.isGameLeader {
                    Button(role: .destructive) {
                        Task { await viewModel.changeGameLeaderPosition(to: 0, for: playerManager.playerProfile!) }
                    } label: {
                        Text("Remove Game Leader Role")
                    }
                } else {
                    Button {
                        Task {
                            await viewModel.changeGameLeaderPosition(to: 2, for: playerManager.playerProfile!)
                        }
                    } label: {
                        Text("Request Game Leader")
                    }
                    .disabled(viewModel.isRequestingGameLeader)
                }
            } footer: {
                if playerManager.playerProfile!.isVerifiedStudent == 1 {
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
