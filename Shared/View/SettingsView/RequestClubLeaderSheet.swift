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
                VStack(spacing: 12) {
                    VStack(alignment: .center) {
                        Text("Request Club Leader")
                            .font(.title)
                            .bold()
                    }
                    VStack(spacing: 12){
                        Text("Requesting the Club Leader role will require manual verification. Enter the club name you are a leader of. You'll be required to submit any links that can identify you as being a leader of the club.")
                        HStack{
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Text(playerManager.playerProfile!.inSchool)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        TextField("Club Name (Ex. Rutgers VALORANT Club)", text: $viewModel.clubLeaderClubName)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.appBackground)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                        Section {
                            TextField("Links", text: $viewModel.clubLeaderRequestDescription, axis: .vertical)
                                .textContentType(.URL)
                                .lineLimit(5, reservesSpace: true)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
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
            .padding(12)
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
