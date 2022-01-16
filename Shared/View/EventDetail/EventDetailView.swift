//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {
    
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
            VStack {
                List {
                    Section(header: Text("Matches")) {
                        ForEach(viewModel.matches) { match in
                            NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match))) {
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
                                viewModel.deleteMatch(recordID: recordID)
                                viewModel.matches.remove(at: index)
                            }
                        }
                        Button {
                            viewModel.isShowingAddMatch = true
                        } label: {
                            Text("Add Match")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $viewModel.isShowingAddMatch) {
                            NavigationView{
                                AddMatchSheet(viewModel: viewModel)
                            }
                        }
                    }

                    Section(header: Text("Players")) {
                        ForEach(viewModel.players, id: \.self){ player in
                            Text(player.firstName)
                        }
                        .onDelete { index in
                            viewModel.players.remove(atOffsets: index)
                        }
                        Button {
                                viewModel.isShowingAddPlayerToEvent = true
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $viewModel.isShowingAddPlayerToEvent) {
                            NavigationView {
                                AddExistingPlayer(viewModel: viewModel)
                            }
                        }
                    }
                }
                .toolbar {
                    EditButton()
                }
                .task {
                    viewModel.getMatchesForEvent()
                }
                
            }
            .navigationTitle(viewModel.event.eventName)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
