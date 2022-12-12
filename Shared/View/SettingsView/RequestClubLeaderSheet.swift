//
//  RequestClubLeaderSheet.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/24/22.
//

import SwiftUI

struct RequestClubLeaderSheet: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: appCellSpacing) {
                    VStack(alignment: .center) {
                        Text("Request Club Leader")
                            .font(.system(.title, design: .rounded, weight: .bold))
                    }
                    VStack(spacing: appCellSpacing){
                        Text("Requesting the Club Leader role will require manual verification. Enter the club name you are a leader of. You'll be required to submit any links that can identify you as being a leader of the club.")
                            .font(.system(.body, design: .rounded, weight: .regular))
                        HStack{
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Text(playerManager.playerProfile!.inSchool)
                                .font(.system(.callout, design: .rounded, weight: .medium))
                        }
                        TextField("Club Name (Ex. Rutgers VALORANT Club)", text: $viewModel.clubLeaderClubName)
                            .font(.system(.body, design: .rounded, weight: .regular))
                            .padding(appCellPadding)
                            .background {
                                RoundedRectangle(cornerRadius: appCornerRadius)
                                    .foregroundColor(.appBackground)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                        Section {
                            TextField("Links", text: $viewModel.clubLeaderRequestDescription, axis: .vertical)
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .textContentType(.URL)
                                .lineLimit(5, reservesSpace: true)
                                .padding(appCellPadding)
                                .background {
                                    RoundedRectangle(cornerRadius: appCornerRadius)
                                        .foregroundColor(.appBackground)
                                }
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        Button("Request Club Leader", action: {
                            Task {
                                await viewModel.changeClubLeaderPosition(to: 2, handledBy: playerManager)
                                viewModel.isShowingRequestClubLeaderSheet = false
                            }
                        })
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .controlSize(.regular)
                        .disabled(viewModel.clubLeaderClubName.isEmpty || viewModel.clubLeaderRequestDescription.isEmpty)
                    }
                    Spacer()
                }
            }
            .padding(appCellPadding)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            viewModel.isShowingRequestClubLeaderSheet = false
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct RequestClubLeaderSheet_Previews: PreviewProvider {
    static var previews: some View {
        RequestClubLeaderSheet(viewModel: SettingsViewModel())
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
