//
//  EventParticipantsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventParticipantsView
//INFO: Displays list of players in the event with the ability for a player to join or leave event. Owners can search and add players.
struct EventParticipantsView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Participants")
                    .font(.title2)
                    .bold()
                Spacer()
                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isPublished == 1 {
                    NavigationLink {
                        AddPlayerToEventSheet(viewModel: viewModel)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 24, design: .default))
                    }
                } else if !viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isPublished == 1 {
                    if let playerProfile = playerManager.playerProfile {
                        if playerProfile.inEvents.contains(where: {$0.recordID == viewModel.event.id}) {
                            Button {
                                viewModel.leaveEvent(with: playerManager)
                            } label: {
                                Text("Leave")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appPrimaryInverse)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.red)
                                    .cornerRadius(4)
                            }
                        } else {
                            Button {
                                viewModel.addPlayerToEvent(with: playerManager)
                            } label: {
                                Text("Join")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appPrimaryInverse)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }

            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.event.isPublished == 0 && viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isArchived == 0 {
                HStack{
                    Spacer()
                    Text("Publish event to manually add players")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
            } else if viewModel.playersInEvent.isEmpty {
                HStack{
                    Spacer()
                    Text("No participants found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                    Spacer()
                }
                .padding()
            } else {
                LazyVStack {
                    ForEach(viewModel.playersInEvent){ player in
                        EventParticipantCell(event: viewModel.event, player: player)
                            .onLongPressGesture {
                                //This stops scrolling
                                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isArchived == 0 {
                                    viewModel.removePlayerFromEventWith(for: player)
                                    //viewModel.refreshEventDetails(with: eventsManager.players)
                                }
                            }
                    }
                }
            }
        }
    }
}
