//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        List {
            Section{
                VStack(alignment: .leading, spacing: 5){
                    Text("Description")
                        .bold()
                        .font(.title3)
                    Text(viewModel.event.eventDescription)
                        .padding(.leading, 10)
                }
                VStack(alignment: .leading, spacing: 5){
                    Text("Location")
                        .bold()
                        .font(.title3)
                    Text(viewModel.event.eventLocation)
                        .padding(.leading, 10)
                }
                .padding(.top, 10)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Section(header: Text("Matches")) {
                ForEach(viewModel.matches) { match in
                    NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: viewModel.playersInEvent, event: viewModel.event))) {
                        VStack(alignment: .leading){
                            Text(match.matchName)
                            Text(match.matchStartTime.convertDateToString())
                                .font(.caption)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive){
                            viewModel.deleteMatch(matchID: match.id)
                            viewModel.matches.removeAll(where: {$0.id == match.id})
                        } label: {
                            Label("Delete Player", systemImage: "minus.circle.fill")
                        }
                    }
                }
                Button {
                    viewModel.sheetToPresent = .addMatch
                    viewModel.resetMatchInput()
                } label: {
                    Text("Add Match")
                        .foregroundColor(.blue)
                }
            }
    
            Section(header: Text("Players")) {
                ForEach(viewModel.playersInEvent){ player in
                    HStack{
                        VStack(alignment: .leading){
                            Text(player.firstName)
                                .bold()
                                .font(.title2)
                            ForEach(eventsManager.playerProfiles[player.id].flatMap({$0}) ?? []){ playerProfile in
                                if playerProfile.gameName == viewModel.event.eventGame {
                                    Text(playerProfile.gameID)
                                        .font(.callout)
                                }
                            }
                        }
                        Spacer()
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive){
                            viewModel.removePlayerFromEventWith(for: player)
                            viewModel.setUpEventDetail(with: eventsManager.players)
                        } label: {
                            Label("Delete Player", systemImage: "minus.circle.fill")
                        }
                    }
                }
                if viewModel.event.eventOwner.recordID == CloudKitManager.shared.userRecord?.recordID {
                    Button {
                        viewModel.sheetToPresent = .addPlayer
                    } label: {
                        Text("Add Player")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle(viewModel.event.eventName)
        .refreshable {
            viewModel.setUpEventDetail(with: eventsManager.players)
        }
        .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
            viewModel.setUpEventDetail(with: eventsManager.players)
        }){
            NavigationView{
                viewModel.presentSheet()
            }
        }
        .task {
            viewModel.setUpEventDetail(with: eventsManager.players)
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
