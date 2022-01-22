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
            Section(header: Text("Matches")) {
                ForEach(viewModel.matches) { match in
                    NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: viewModel.playersInEvent, event: viewModel.event))) {
                        VStack(alignment: .leading){
                            Text(match.matchName)
                            Text(match.matchStartTime.convertDateToString())
                                .font(.caption)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recordID = viewModel.matches[index].id
                        viewModel.deleteMatch(matchID: recordID)
                        viewModel.matches.remove(at: index)
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
                            //Handle Later: Multiple games
//                            Text(manager.playerDetails[player.id]![0].gameID)
//                                .font(.callout)
                        }
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    viewModel.removePlayerFromEventWith(indexSet: indexSet)
                }
                Button {
                    viewModel.sheetToPresent = .addPlayer
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(viewModel.event.eventName)
        .refreshable {
            viewModel.setUpEventDetail(with: eventsManager.players)
        }
        .sheet(isPresented: $viewModel.isShowingSheet){
            NavigationView{
                viewModel.presentSheet()
            }
        }
        .task {
            viewModel.setUpEventDetail(with: eventsManager.players)
        }
        .toolbar {
            EditButton()
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
