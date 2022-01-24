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
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Game Profiles")
                .bold()
                .font(.title2)
                .accessibilityAddTraits(.isHeader)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),spacing: 25) {
                    ForEach(viewModel.playerDetails) { gameDetail in
                        PlayerGameDetailCell(gameDetail: gameDetail)
                            .onLongPressGesture {
                                viewModel.deleteGameDetail(for: gameDetail.id)
                            }
                    }
                    AddGameDetailCell()
                        .onTapGesture {
                            viewModel.isPresentingSheet = true
                            viewModel.resetInput()
                        }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(viewModel.player.firstName)
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .task {
            viewModel.getPlayersAndDetails(for: eventsManager)
        }
        .sheet(isPresented: $viewModel.isPresentingSheet) {
            NavigationView {
                AddPlayerGameDetailSheet(viewModel: viewModel)
            }
        }
    }
}

struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileView(viewModel: PlayerProfileViewModel(player: TUPlayer(record: MockData.player)))
    }
}

struct AddGameDetailCell: View {
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
