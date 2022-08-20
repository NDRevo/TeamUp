//
//  SettingsView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import SwiftUI

struct SettingsView: View {

    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        List {
            Section {
                Button {
                    Task{
                        viewModel.isShowingWebsite = true
                    }
                } label: {
                    Text("Verify Student")
                }
                .disabled(CloudKitManager.shared.playerProfile!.isVerifiedStudent == 1)
                if CloudKitManager.shared.playerProfile!.isVerifiedStudent == 1 {
                    Button {
                        Task{
                            viewModel.hasVerified = false
                        }
                    } label: {
                        Text("Unverify Student")
                    }
                }
            }
            
            Section {
                Button {
                    Task {
                        await viewModel.changeGameLeaderPosition(to: 2)
                    }
                } label: {
                    Text(CloudKitManager.shared.playerProfile?.isGameLeader == 2 ? "Requested Game Leader" : "Request Game Leader")
                }
                .disabled(CloudKitManager.shared.playerProfile?.isGameLeader == 2 || CloudKitManager.shared.playerProfile?.isGameLeader == 1)
                
                
                Button(role: .destructive) {
                    Task {
                        await viewModel.changeGameLeaderPosition(to: 0)
                    }
                } label: {
                    Text("Remove Game Leader Role")
                }
                //Add revoke
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
